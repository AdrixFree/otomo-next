///////////////////////////////////////////////////////////
//
//                         OTOMO
//               Radar + Assit for Interlude
//                by LanGhost (c) 2020-2021
//
///////////////////////////////////////////////////////////

unit MMBuff;

interface

uses
    Helpers;

const
    MYSTIC_BUFFS_COUNT = 6;

type
    TMysticBuff = class
    private
        IsFastRes: boolean;
        IsCheckCancel: boolean;
        IsCrystal: boolean;
        IsSelfNobless: boolean;

        FoundCancel: boolean;
        Buffs: array[1..MYSTIC_BUFFS_COUNT] of integer;

        procedure Resurrection();
        procedure FindCancelCooldown();
    public
        procedure SetFastRes(status: boolean);
        procedure SetCheckCancel(status: boolean);
        procedure SetCrystal(status: boolean);
        procedure SetSelfNobl(status: boolean);

        constructor Create();
        procedure SelfBuff(role: integer);
    end;

implementation

const
    MYSTIC_ELEXIR_MIN_HP = 15;
    MYSTIC_ELEXIR_MIN_CP = 15;
    MYSTIC_BUFF_RETRIES = 10;
    MYSTIC_RESIST_AQUA_DISTANCE = 400;
    MYSTIC_CANCEL_END_SOUND = 'cancel.wav';
    MYSTIC_ROLE_RADAR = 1;

///////////////////////////////////////////////////////////
//
//                        PUBLIC VARS
//
///////////////////////////////////////////////////////////

procedure TMysticBuff.SetCheckCancel(status: boolean);
begin
    if (status <> self.IsCheckCancel)
    then begin
        if (status)
        then PrintBotMsg('Find cancel cooldown: ON')
        else PrintBotMsg('Find cancel cooldown: OFF');
    end;

    self.IsCheckCancel := status;
end;

procedure TMysticBuff.SetFastRes(status: boolean);
begin
    if (status <> self.IsFastRes)
    then begin
        if (status)
        then PrintBotMsg('Fast ressurection: ON')
        else PrintBotMsg('Fast ressurection: OFF');
    end;

    self.IsFastRes := status;
end;

procedure TMysticBuff.SetCrystal(status: boolean);
begin
    if (status <> self.IsCrystal)
    then begin
        if (status)
        then PrintBotMsg('Sanctity crystal buff: ON')
        else PrintBotMsg('Sanctity crystal buff: OFF');
    end;

    self.IsCrystal := status;
end;

procedure TMysticBuff.SetSelfNobl(status: boolean);
begin
    if (status <> self.IsSelfNobless)
    then begin
        if (status)
        then PrintBotMsg('Self nobless check: ON')
        else PrintBotMsg('Self nobless check: OFF');
    end;

    self.IsSelfNobless := status;
end;

///////////////////////////////////////////////////////////
//
//                      PUBLIC FUNCTIONS
//
///////////////////////////////////////////////////////////

constructor TMysticBuff.Create();
begin
    inherited;

    self.Buffs[1] := ARCANE_BUFF;
    self.Buffs[2] := CRYSTAL_BUFF;
    self.Buffs[3] := RESIST_AQUA_BUFF;
    self.Buffs[4] := WIND_WALK_BUFF;
    self.Buffs[5] := ACUMEN_BUFF;
    self.Buffs[6] := NOBLESS_BUFF;
end;

procedure TMysticBuff.SelfBuff(role: integer);
var
    i, j: integer;
    buff: TL2Skill;
begin
    if (self.IsCheckCancel)
    then self.FindCancelCooldown();

    for i := 1 to MYSTIC_BUFFS_COUNT do
    begin
        for j := 0 to MYSTIC_BUFF_RETRIES do
        begin
            if (User.Dead())
            then self.Resurrection();

            if (not User.Buffs.ByID(self.Buffs[i], buff))
            then begin
                if (self.Buffs[i] = CRYSTAL_BUFF)
                then begin
                    if (not self.IsCrystal)
                    then continue;

                    Engine.UseItem(CRYSTAL_ITEM);
                    Delay(100);
                    continue;
                end;

                if (self.Buffs[i] = RESIST_AQUA_BUFF)
                then begin
                    if (role = MYSTIC_ROLE_RADAR)
                    then begin
                        if (not User.Buffs.ByID(SURRENDER_WATER_SKILL, buff))
                        then begin
                            delay(100);
                            Engine.SetTarget(User);
                            Engine.UseSkill(RESIST_AQUA_BUFF);
                            Delay(300);
                        end;
                    end;
                    continue;
                end;

                if (self.Buffs[i] = WIND_WALK_BUFF)
                then begin
                    if (not User.Buffs.ByID(PAAGRIO_HASTE_BUFF, buff)) and
                        (not User.Buffs.ByID(HASTE_POTION_BUFF, buff))
                    then begin
                        Engine.UseItem(HASTE_POTION_ITEM);
                        Delay(100);
                        continue;
                    end;
                end;

                if (self.Buffs[i] = ACUMEN_BUFF)
                then begin
                    if (not User.Buffs.ByID(WISDOM_PAAGRIO_BUFF, buff)) and
                        (not User.Buffs.ByID(MAGIC_HASTE_POTION_BUFF, buff))
                    then begin
                        Engine.UseItem(MAGIC_HASTE_POTION_ITEM);
                        Delay(100);
                        continue;
                    end;
                end;

                if (self.Buffs[i] = NOBLESS_BUFF)
                then Engine.SetTarget(User);

                Engine.UseSkill(self.Buffs[i]);

                if (self.Buffs[i] = ARCANE_BUFF)
                then Delay(400);
            end
            else break;
            delay(100);
        end;
    end;

    if (User.HP < MYSTIC_ELEXIR_MIN_HP) and (not User.Dead)
    then Engine.UseItem(ELEXIR_HP_ITEM);

    if (User.CP < MYSTIC_ELEXIR_MIN_CP) and (not User.Dead)
    then Engine.UseItem(ELEXIR_CP_ITEM);
end;

///////////////////////////////////////////////////////////
//
//                      PRIVATE FUNCTIONS
//
///////////////////////////////////////////////////////////

procedure TMysticBuff.Resurrection();
var
    i: integer;
    buff: TL2Skill;
    target: TL2Char;
begin
    while (not User.Buffs.ByID(NOBLESS_BUFF, buff)) do
    begin
        if (self.IsSelfNobless)
        then begin
            if (User.Dead) and (User.AbnormalID <= 2) and (self.IsFastRes)
            then Engine.ConfirmDialog(true);

            Engine.SetTarget(User);
            Engine.DUseSkill(NOBLESS_BUFF, false, false);
        end;
        delay(200);
    end;
end;

procedure TMysticBuff.FindCancelCooldown();
var
    skill: TL2Skill;
begin
    if (Engine.GetSkillList.ByID(CANCEL_SKILL, skill))
    then begin
        if (skill.EndTime() > 0)
        then self.FoundCancel := true;

        if (skill.EndTime <= 0) and (self.FoundCancel)
        then begin
            self.FoundCancel := false;
            PlaySound(script.Path + MYSTIC_CANCEL_END_SOUND);
        end;
    end;
end;

end.