///////////////////////////////////////////////////////////
//
//                          OTOMO
//               Radar + Assit for Interlude
//                by LanGhost (c) 2020-2021
//
///////////////////////////////////////////////////////////

unit MMAttack;

interface

uses
    Helpers, Classes, Packets, SysUtils;

const
    MYSTIC_AUTO_ATTACK_RANGE_LONG = 1;
    MYSTIC_AUTO_ATTACK_RANGE_MILI = 2;

    MYSTIC_AUTO_ATTACK_SURRENDER = 1;
    MYSTIC_AUTO_ATTACK_LIGHT = 2;
    MYSTIC_AUTO_ATTACK_ICE = 3;
    MYSTIC_AUTO_ATTACK_SOLAR = 4;
    MYSTIC_AUTO_ATTACK_FLARE = 5;
    MYSTIC_AUTO_ATTACK_BOLT = 6;

    MYSTIC_AUTO_ATTACK_RANGE_COUNT = 4;
    MYSTIC_AUTO_ATTACK_MILI_COUNT = 1;
    MYSTIC_AUTO_ATTACK_FLASH_COUNT = 7;

    MYSTIC_RESKILL_RANGE_900 = 900;
    MYSTIC_RESKILL_RANGE_400 = 400;

type
    TMysticAttack = class
    private
        LongAttackType: integer;
        MiliAttackType: integer;
        AttackRange: integer;
        AttackStatus: boolean;
        LastTargetName: string;
        ReskillDelay: integer;
        FlashUsers: TList;
        ReskillRange: integer;
        IgnoreClans: TStringList;
        SurrRangeSkills: array[1..MYSTIC_AUTO_ATTACK_RANGE_COUNT] of integer;
        LightRangeSkills: array[1..MYSTIC_AUTO_ATTACK_RANGE_COUNT] of integer;
        IceRangeSkills: array[1..MYSTIC_AUTO_ATTACK_RANGE_COUNT] of integer;
        SolarRangeSkills: array[1..MYSTIC_AUTO_ATTACK_RANGE_COUNT] of integer;
        MiliSkillsBolt: array[1..MYSTIC_AUTO_ATTACK_MILI_COUNT] of integer;
        MiliSkillsFlare: array[1..MYSTIC_AUTO_ATTACK_MILI_COUNT] of integer;
        FlashSkills: array[1..MYSTIC_AUTO_ATTACK_FLASH_COUNT] of integer;

        procedure SurrAutoAttack();
        procedure LightAutoAttack();
        procedure IceAutoAttack();
        procedure SolarAutoAttack();
        procedure FlareAutoAttack();
        procedure BoltAutoAttack();
        procedure SetReskillRange(range: integer);
    public
        procedure SetRange(range: integer);
        procedure SetType(range: integer; atkType: integer);
        procedure SetAttackStatus(status: boolean);
        procedure SetReskillDelay(del: integer);
        procedure AddIgnoreClan(clan: string);
        function GetType(range: integer): integer;
        function GetRange(): integer;
        function GetAttackStatus(): boolean;

        constructor Create();
        procedure Attack();
        procedure AutoFlashPacket(data: pointer; size: word);
        procedure AutoFlash();
        procedure Reskill();
        procedure Cancel();
    end;

implementation

const
    MYSTIC_MIN_CAST_SPD = 1671;
    MYSTIC_FLASH_SKILL_RETRIES = 20;
    MYSTIC_FLASH_DISTANCE = 200;
    CANCEL_SKILL_RETRIES = 20;

///////////////////////////////////////////////////////////
//
//                        PUBLIC VARS
//
///////////////////////////////////////////////////////////

procedure TMysticAttack.SetRange(range: integer);
begin
    if (range <> self.AttackRange)
    then begin
        if (range = MYSTIC_AUTO_ATTACK_RANGE_LONG)
        then begin
            PrintBotMsg('Auto attack range: LONG');
            self.SetReskillRange(MYSTIC_RESKILL_RANGE_900);
        end
        else if (range = MYSTIC_AUTO_ATTACK_RANGE_MILI)
        then begin
            PrintBotMsg('Auto attack range: MILI');
            self.SetReskillRange(MYSTIC_RESKILL_RANGE_400);
        end;
    end;

    self.AttackRange := range;
end;

procedure TMysticAttack.SetType(range: integer; atkType: integer);
begin
    if (range = MYSTIC_AUTO_ATTACK_RANGE_LONG)
    then begin
        if (self.LongAttackType <> atkType)
        then begin
            if (atkType = MYSTIC_AUTO_ATTACK_SOLAR)
            then PrintBotMsg('Auto attack type: SOLAR')
            else if (atkType = MYSTIC_AUTO_ATTACK_ICE)
            then PrintBotMsg('Auto attack type: ICE VORTEX')
            else if (atkType = MYSTIC_AUTO_ATTACK_LIGHT)
            then PrintBotMsg('Auto attack type: LIGHT VORTEX')
            else if (atkType = MYSTIC_AUTO_ATTACK_SURRENDER)
            then PrintBotMsg('Auto attack type: SURRENDER');
        end;
        self.LongAttackType := atkType
    end
    else if (range = MYSTIC_AUTO_ATTACK_RANGE_MILI)
    then begin
        if (self.MiliAttackType <> atkType)
        then begin
            if (atkType = MYSTIC_AUTO_ATTACK_BOLT)
            then PrintBotMsg('Auto attack type: BOLT')
            else if (atkType = MYSTIC_AUTO_ATTACK_FLARE)
            then PrintBotMsg('Auto attack type: FLARE');
        end;
        self.MiliAttackType := atkType;
    end;
end;

function TMysticAttack.GetType(range: integer): integer;
begin
    if (range = MYSTIC_AUTO_ATTACK_RANGE_LONG)
    then result := self.LongAttackType
    else if (range = MYSTIC_AUTO_ATTACK_RANGE_MILI)
    then result := self.MiliAttackType;
end;

function TMysticAttack.GetRange(): integer;
begin
    result := self.AttackRange;
end;

procedure TMysticAttack.SetAttackStatus(status: boolean);
begin
    if (status <> self.AttackStatus)
    then begin
        if (status)
        then PrintBotMsg('Auto attack: ON')
        else PrintBotMsg('Auto attack: OFF');
    end;

    self.AttackStatus := status;
end;

function TMysticAttack.GetAttackStatus(): boolean;
begin
    result := self.AttackStatus;
end;

procedure TMysticAttack.SetReskillDelay(del: integer);
begin
    if (del <> self.ReskillDelay)
    then PrintBotMsg('Reskill delay: ' + IntToStr(del));

    self.ReskillDelay := del;
end;

procedure TMysticAttack.SetReskillRange(range: integer);
begin
    self.ReskillRange := range;
end;

procedure TMysticAttack.AddIgnoreClan(clan: string);
begin
    self.IgnoreClans.Add(clan);
end;

///////////////////////////////////////////////////////////
//
//                      PUBLIC FUNCTIONS
//
///////////////////////////////////////////////////////////

constructor TMysticAttack.Create();
begin
    inherited;

    self.FlashUsers := TList.Create();
    self.IgnoreClans := TStringList.Create();

    self.SurrRangeSkills[1] := SOLAR_FLARE_SKILL;
    self.SurrRangeSkills[2] := HYDRO_BLAST_SKILL;
    self.SurrRangeSkills[3] := HYDRO_BLAST_SKILL;
    self.SurrRangeSkills[4] := ICE_DAGGER_SKILL;

    self.LightRangeSkills[1] := SOLAR_FLARE_SKILL;
    self.LightRangeSkills[2] := LIGHT_VORTEX_SKILL;
    self.LightRangeSkills[3] := HYDRO_BLAST_SKILL;
    self.LightRangeSkills[4] := ICE_DAGGER_SKILL;

    self.IceRangeSkills[1] := SOLAR_FLARE_SKILL;
    self.IceRangeSkills[2] := ICE_VORTEX_SKILL;
    self.IceRangeSkills[3] := HYDRO_BLAST_SKILL;
    self.IceRangeSkills[4] := ICE_DAGGER_SKILL;

    self.SolarRangeSkills[1] := SOLAR_FLARE_SKILL;
    self.SolarRangeSkills[2] := HYDRO_BLAST_SKILL;
    self.SolarRangeSkills[3] := HYDRO_BLAST_SKILL;
    self.SolarRangeSkills[4] := ICE_DAGGER_SKILL;

    self.MiliSkillsBolt[1] := AURA_BOLT_SKILL;
    self.MiliSkillsFlare[1] := AURA_FLARE_SKILL;

    self.FlashSkills[1] := NOBLESS_SKILL;
    self.FlashSkills[2] := RESURECTION_SKILL;
    self.FlashSkills[3] := MASS_RESURECTION_SKILL;
    self.FlashSkills[4] := FOE_SKILL;
    self.FlashSkills[5] := ALI_CLEANSE;
    self.FlashSkills[6] := CELESTIAL_SHIELD;
    self.FlashSkills[7] := SPELL_FORCE_SKILL;
end;

procedure TMysticAttack.Attack();
var
    i: integer;
begin
    if (self.AttackStatus)
    then begin
        for i := 0 to self.IgnoreClans.Count - 1 do
        begin
            if (IgnoreClans[i] = User.Target.Clan)
            then exit();
        end;

        if (self.AttackRange = MYSTIC_AUTO_ATTACK_RANGE_LONG)
        then begin
            if (self.LongAttackType = MYSTIC_AUTO_ATTACK_SURRENDER)
            then self.SurrAutoAttack()
            else if (self.LongAttackType = MYSTIC_AUTO_ATTACK_LIGHT)
            then self.LightAutoAttack()
            else if (self.LongAttackType = MYSTIC_AUTO_ATTACK_ICE)
            then self.IceAutoAttack()
            else if (self.LongAttackType = MYSTIC_AUTO_ATTACK_SOLAR)
            then self.SolarAutoAttack();
        end
        else if (self.AttackRange = MYSTIC_AUTO_ATTACK_RANGE_MILI)
        then begin
            if (self.MiliAttackType = MYSTIC_AUTO_ATTACK_FLARE)
            then self.FlareAutoAttack()
            else if (self.MiliAttackType = MYSTIC_AUTO_ATTACK_BOLT)
            then self.BoltAutoAttack()
        end;
    end;
end;

procedure TMysticAttack.AutoFlashPacket(data: pointer; size: word);
var
    packet: TNetworkPacket;
    oid, skill, i: cardinal;
begin
    packet := TNetworkPacket.Create(data, size);
    oid := packet.ReadD();
    packet.ReadD();
    skill := packet.ReadD();
    packet.Free();

    for i := 1 to MYSTIC_AUTO_ATTACK_FLASH_COUNT do
    begin
        if (skill = self.FlashSkills[i])
        then begin
            self.FlashUsers.Add(Pointer(oid));
            exit;
        end;
    end;
end;

procedure TMysticAttack.AutoFlash();
var
    target: TL2Char;
    i, j: integer;
    skill: TL2Skill;
begin
    for i := 0 to self.FlashUsers.Count - 1 do
    begin
        if (i > self.FlashUsers.Count - 1)
        then break;

        if (CharList.ByOID(Cardinal(self.FlashUsers[i]), target))
        then begin
            if (not target.Dead()) and (target.ClanID() <> User.ClanID())
                and (User.DistTo(target) <= MYSTIC_FLASH_DISTANCE) and (not target.IsMember())
            then begin
                for j := 1 to MYSTIC_FLASH_SKILL_RETRIES do
                begin
                    delay(100);

                    // Exit if user not valid
                    if (not UserValid())
                    then break;

                    Engine.GetSkillList.ByID(AURA_FLASH_SKILL, skill);
                    Engine.DUseSkill(AURA_FLASH_SKILL, false, false);

                    if (skill.EndTime() > 0) or (User.Dead())
                    then break;
                end;
            end;
        end;
        self.FlashUsers.Delete(i);
    end;
end;

///////////////////////////////////////////////////////////
//
//                      PRIVATE FUNCTIONS
//
///////////////////////////////////////////////////////////

procedure TMysticAttack.SurrAutoAttack();
var
    i: integer;
    skill: TL2Skill;
begin
    for i := 1 to MYSTIC_AUTO_ATTACK_RANGE_COUNT do
    begin
        // Exit if status is off
        if (not self.AttackStatus) or (not UserValid())
        then break;

        // Check cast speed for Ice Dagger
        if (self.SurrRangeSkills[i] = ICE_DAGGER_SKILL)
            and (User.AtkSpd > MYSTIC_MIN_CAST_SPD)
        then continue;

        if (User.Target.Name() <> self.LastTargetName)
        then begin
            // Cast Surrender only one time per target
            Delay(300);
            Engine.DUseSkill(SURRENDER_WATER_SKILL, false, false);
            self.LastTargetName := User.Target.Name();
        end
        else begin
            // Check solar flare cooldown
            Engine.GetSkillList.ByID(SOLAR_FLARE_SKILL, skill);

            // Prefer Solar Flare skill
            if (self.SurrRangeSkills[i] <> SOLAR_FLARE_SKILL) and (skill.EndTime() = 0)
            then Engine.DUseSkill(SOLAR_FLARE_SKILL, false, false)
            else Engine.DUseSkill(self.SurrRangeSkills[i], false, false);
        end;
        Delay(200);
    end;
end;

procedure TMysticAttack.LightAutoAttack();
var
    i: integer;
    skill: TL2Skill;
begin
    for i := 1 to MYSTIC_AUTO_ATTACK_RANGE_COUNT do
    begin
        // Exit if status is off
        if (not self.AttackStatus) or (not UserValid())
        then break;

        // Check cast speed for Ice Dagger
        if (self.LightRangeSkills[i] = ICE_DAGGER_SKILL)
            and (User.AtkSpd > MYSTIC_MIN_CAST_SPD)
        then continue;

        // Check solar flare cooldown
        Engine.GetSkillList.ByID(SOLAR_FLARE_SKILL, skill);

        // Prefer Solar Flare skill
        if (self.LightRangeSkills[i] <> SOLAR_FLARE_SKILL) and (skill.EndTime() = 0)
        then Engine.DUseSkill(SOLAR_FLARE_SKILL, false, false)
        else Engine.DUseSkill(self.LightRangeSkills[i], false, false);

        Delay(200);
    end;
end;

procedure TMysticAttack.IceAutoAttack();
var
    i: integer;
    skill: TL2Skill;
begin
    for i := 1 to MYSTIC_AUTO_ATTACK_RANGE_COUNT do
    begin
        // Exit if status is off
        if (not self.AttackStatus) or (not UserValid())
        then break;

        // Check cast speed for Ice Dagger
        if (self.IceRangeSkills[i] = ICE_DAGGER_SKILL)
            and (User.AtkSpd > MYSTIC_MIN_CAST_SPD)
        then continue;

        // Check solar flare cooldown
        Engine.GetSkillList.ByID(SOLAR_FLARE_SKILL, skill);

        // Prefer Solar Flare skill
        if (self.IceRangeSkills[i] <> SOLAR_FLARE_SKILL) and (skill.EndTime() = 0)
        then Engine.DUseSkill(SOLAR_FLARE_SKILL, false, false)
        else Engine.DUseSkill(self.IceRangeSkills[i], false, false);

        Delay(200);
    end;
end;

procedure TMysticAttack.SolarAutoAttack();
var
    i: integer;
    skill: TL2Skill;
begin
    for i := 1 to MYSTIC_AUTO_ATTACK_RANGE_COUNT do
    begin
        // Exit if status is off
        if (not self.AttackStatus) or (not UserValid())
        then break;

        // Check cast speed for Ice Dagger
        if (self.SolarRangeSkills[i] = ICE_DAGGER_SKILL)
            and (User.AtkSpd > MYSTIC_MIN_CAST_SPD)
        then continue;

        // Check solar flare cooldown
        Engine.GetSkillList.ByID(SOLAR_FLARE_SKILL, skill);

        // Prefer Solar Flare skill
        if (self.SolarRangeSkills[i] <> SOLAR_FLARE_SKILL) and (skill.EndTime() = 0)
        then Engine.DUseSkill(SOLAR_FLARE_SKILL, false, false)
        else Engine.DUseSkill(self.SolarRangeSkills[i], false, false);

        Delay(200);
    end;
end;

procedure TMysticAttack.FlareAutoAttack();
var
    i: integer;
begin
    for i := 1 to MYSTIC_AUTO_ATTACK_MILI_COUNT do
    begin
        // Exit if status is off
        if (not self.AttackStatus) or (not UserValid())
        then break;

        // Prefer Solar Flare skill
        Engine.DUseSkill(self.MiliSkillsFlare[i], false, false);

        Delay(10);
    end;
end;

procedure TMysticAttack.BoltAutoAttack();
var
    i: integer;
begin
    for i := 1 to MYSTIC_AUTO_ATTACK_MILI_COUNT do
    begin
        // Exit if status is off
        if (not self.AttackStatus) or (not UserValid())
        then break;

        // Prefer Solar Flare skill
        Engine.DUseSkill(self.MiliSkillsBolt[i], false, false);

        Delay(10);
    end;
end;

procedure TMysticAttack.Reskill();
var
    p1, p2: pointer;
    enemy: TL2Live;
    target: TL2Char;
    i: integer;
    excluded: boolean;          
begin
    excluded := false;

    Engine.WaitAction([laRevive], p1, p2);
    enemy := TL2Live(p1);

    if (not UserValid())
    then exit();

    if (CharList.ByName(enemy.Name, target))
    then begin
        if (User.DistTo(target) <= self.ReskillRange)
            and (not target.Dead) and (target.ClanID <> User.ClanID)
            and (not target.IsMember) and (not User.Dead)
        then begin

            for i := 0 to IgnoreClans.Count - 1 do
            begin
                if (IgnoreClans[i] = target.Clan)
                then begin
                    excluded := true;
                    break;
                end;
            end;

            if (excluded)
            then exit();

            Engine.SetTarget(target);
            Delay(self.ReskillDelay);
        end;
    end;
end;

procedure TMysticAttack.Cancel();
var
    i: integer;
    cancel, chaos: TL2Skill;
begin
    for i := 1 to CANCEL_SKILL_RETRIES do
    begin
        if (not UserValid())
        then break;

        delay(100);

        Engine.GetSkillList.ByID(ARCANE_CHAOS_SKILL, chaos);
        Engine.GetSkillList.ByID(CANCEL_SKILL, cancel);

        if (chaos.EndTime = 0)
        then Engine.DUseSkill(ARCANE_CHAOS_SKILL, false, false)
        else Engine.DUseSkill(CANCEL_SKILL, false, false);

        if (cancel.EndTime > 0) or (User.Target.Dead)
        then break;
    end;
end;


end.