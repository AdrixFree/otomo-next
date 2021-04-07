///////////////////////////////////////////////////////////
//
//                          OTOMO
//               Radar + Assit for Interlude
//                by LanGhost (c) 2020-2021
//
///////////////////////////////////////////////////////////

unit MM;

interface

uses
    MMAttack, MMTarget, Helpers, MMBuff;

const
    MM_ROLE_RADAR = 1;
    MM_ROLE_ASSIST = 2;

type
    TMysticMuse = class
    private
        AutoAttack: TMysticAttack;
        Target: TMysticTarget;
        Buffer: TMysticBuff;

        Role: integer;
    public
        procedure SetRole(role: integer);
        procedure SetAutoAttack(status: boolean);
        procedure SetAutoAttackRange(range: integer);
        procedure SetAutoAttackType(atkType: integer);
        procedure SetTargetIgnoreWl(status: boolean);
        procedure SetFindAfterKill(status: boolean);
        procedure SetTargetClass(cls: integer);
        procedure SetCheckCancel(status: boolean);
        procedure SetFastRessurection(status: boolean);
        procedure SetCrystalBuffCheck(status: boolean);
        procedure SetSelfNoblCheck(status: boolean);

        constructor Create();
        procedure RunAutoAttack();
        procedure FindTarget();
        procedure FindTargetAfterKill();
        procedure TargetHold();
        procedure TargetSave();
        procedure AutoFlash();
        procedure SelfBuff();
        procedure AutoFlashPacket(data: pointer; size: word);
    end;

var
    MysticMuse: TMysticMuse;

implementation

///////////////////////////////////////////////////////////
//
//                        PUBLIC VARS
//
///////////////////////////////////////////////////////////

procedure TMysticMuse.SetAutoAttack(status: boolean);
begin
    self.AutoAttack.SetAttackStatus(status);
end;

procedure TMysticMuse.SetAutoAttackRange(range: integer);
begin
    self.AutoAttack.SetRange(range);
end;

procedure TMysticMuse.SetAutoAttackType(atkType: integer);
begin
    self.AutoAttack.SetType(atkType);
end;

procedure TMysticMuse.SetTargetIgnoreWl(status: boolean);
begin
    self.Target.SetIgnoreWl(status);
end;

procedure TMysticMuse.SetFindAfterKill(status: boolean);
begin
    self.Target.SetFindAfterKill(status);
end;

procedure TMysticMuse.SetTargetClass(cls: integer);
begin
    self.Target.SetClass(cls);
end;

procedure TMysticMuse.SetRole(role: integer);
begin
    if (role <> self.Role)
    then begin
        if (role = MM_ROLE_RADAR)
        then PrintBotMsg('Player role: RADAR')
        else if (role = MM_ROLE_ASSIST)
        then PrintBotMsg('Player role: ASSIST');
    end;

    self.Role := role;
end;

procedure TMysticMuse.SetCheckCancel(status: boolean);
begin
    self.Buffer.SetCheckCancel(status);
end;

procedure TMysticMuse.SetFastRessurection(status: boolean);
begin
    self.Buffer.SetFastRes(status);
end;

procedure TMysticMuse.SetCrystalBuffCheck(status: boolean);
begin
    self.Buffer.SetCrystal(status);
end;

procedure TMysticMuse.SetSelfNoblCheck(status: boolean);
begin
    self.Buffer.SetSelfNobl(status);
end;

///////////////////////////////////////////////////////////
//
//                      PUBLIC FUNCTIONS
//
///////////////////////////////////////////////////////////

constructor TMysticMuse.Create();
begin
    inherited;

    self.AutoAttack := TMysticAttack.Create();
    self.Target := TMysticTarget.Create();
    self.Buffer := TMysticBuff.Create();

    self.SetRole(MM_ROLE_RADAR);
    self.SetAutoAttack(false);
    self.SetAutoAttackRange(MYSTIC_AUTO_ATTACK_RANGE_LONG);
    self.SetAutoAttackType(MYSTIC_AUTO_ATTACK_SURRENDER);
    self.SetTargetIgnoreWl(false);
    self.SetFindAfterKill(true);
    self.SetTargetClass(ALL_CLASS);
    self.Buffer.SetFastRes(false);
    self.Buffer.SetCheckCancel(true);
    self.Buffer.SetCrystal(false);
    self.Buffer.SetSelfNobl(true);
end;

procedure TMysticMuse.RunAutoAttack();
begin
    self.AutoAttack.Attack();
end;

procedure TMysticMuse.AutoFlashPacket(data: pointer; size: word);
begin
    self.AutoAttack.AutoFlashPacket(data, size);
end;

procedure TMysticMuse.AutoFlash();
begin
    self.AutoAttack.AutoFlash();
end;

procedure TMysticMuse.FindTarget();
begin
    if (self.Role = MM_ROLE_RADAR)
    then self.Target.FindTarget();
end;

procedure TMysticMuse.FindTargetAfterKill();
begin
    if (self.Role = MM_ROLE_RADAR)
    then self.Target.FindTargetAfterKill();
end;

procedure TMysticMuse.TargetHold();
begin
    self.Target.Hold();
end;

procedure TMysticMuse.TargetSave();
begin
    self.Target.Save();
end;

procedure TMysticMuse.SelfBuff();
begin
    self.Buffer.SelfBuff(self.Role);
end;


end.