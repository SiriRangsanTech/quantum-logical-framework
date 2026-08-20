import QLF_ChargeCensus
import QLF_BaryonWinding

set_option linter.unusedVariables false

/-!
# QLF_ChargeBalance — anomaly cancellation is a ZFA charge-balance: `Σ Q = 0` per generation

`QLF_ChargeCensus` summed the *squared* charges (`Σ Nᶜ Q_f² = 8 = 2³`, the running weight). The
*signed* sum is the complementary fact, and it is a substrate balance: **a complete Standard-Model
generation is electrically neutral** — `Σ Q = 0` — because electric charge is a **signed twist count**
(`QLF_BMinusL`: `charge = signed_count`, conserved and zero on every ZFA closure), so a generation's
charge ledger *closes*. What particle physics calls **anomaly cancellation / matter neutrality** is,
on the substrate, the ZFA charge-balance condition (`Σ_pos = Σ_neg`).

## The balance

With QLF's derived charges — neutrino `0` (`neutrino_neutral`), charged lepton `−1` (unit winding),
quarks `+2/3` / `−1/3` (thirds forced by the 3 colours, `QLF_QuarkStructure`) — and quarks counted
with their 3 colours, one generation sums to

  `Σ Q = 0 + (−1) + 3·(2/3) + 3·(−1/3) = 0 + (−1) + 2 + (−1) = 0`  (`gen_electric_neutral`).

This is **not** a trivial `0 = 0`: the positive charge (`up-type +2`) balances the negative
(`charged-lepton + down-type = −2`), `2 = 2` (`gen_charge_balanced`, `genPositiveCharge_eq_two`) — the
`+2/3` and `−1/3` thirds are *exactly* what makes the ledger close, so the three colours (which force
the thirds) are what make matter neutral. Concrete closures: the proton `uud = +1`
(`proton_charge_one`), the neutron `udd = 0` (`neutron_charge_zero`), and the hydrogen atom
`proton + electron = 0` (`hydrogen_neutral`).

## Honest scope

This anchors the **electric-charge** anomaly / neutrality balance (`Σ Q = 0`) as ZFA charge-closure —
the substrate reading of why matter is neutral and the electromagnetic gauge theory is anomaly-free.
The *full* set of Standard-Model anomaly conditions (the hypercharge `Σ Y`, `Σ Y³`, the mixed
`SU(2)²·Y`, `SU(3)²·Y`, and gravitational `Σ Y` anomalies) is the broader statement; those need the
hypercharge assignments, tracked with the electroweak sector (`QLF_WeinbergAngle`/`QLF_SU5`). Reuses
`QLF_ChargeCensus`; no new axioms. See `QLF_BMinusL`, `Quarks.md`, `Standard_Model.md`.
-/

namespace QLF

/-! ### QLF-derived electric charges -/

/-- Neutrino charge `0` (`QLF_Spin.neutrino_neutral`). -/
def chargeNu : ℚ := 0
/-- Charged-lepton charge `−1` (unit twist winding). -/
def chargeE : ℚ := -1
/-- Up-type quark charge `+2/3` (`QLF_QuarkStructure`, thirds from the 3 colours). -/
def chargeU : ℚ := 2 / 3
/-- Down-type quark charge `−1/3` (`QLF_QuarkStructure.down_quark_charge_third`). -/
def chargeD : ℚ := -1 / 3

/-! ### One generation is electrically neutral -/

/-- The electric charge of one complete generation (all fermions, quarks with their 3 colours):
    `ν + e + 3u + 3d`. -/
def genElectricCharge : ℚ := chargeNu + chargeE + 3 * chargeU + 3 * chargeD

/-- **A complete generation is electrically neutral — `Σ Q = 0`.** Electric charge is a signed twist
    count (`QLF_BMinusL`), so a generation's charge ledger is ZFA-balanced (`Σ_pos = Σ_neg`): anomaly
    cancellation / neutrality *is* charge closure. -/
theorem gen_electric_neutral : genElectricCharge = 0 := by
  norm_num [genElectricCharge, chargeNu, chargeE, chargeU, chargeD]

/-- The total positive charge in a generation (up-type, `3·(2/3)`). -/
def genPositiveCharge : ℚ := 3 * chargeU
/-- The total negative charge in a generation (charged lepton + down-type, `−1 + 3·(−1/3)`). -/
def genNegativeCharge : ℚ := chargeE + 3 * chargeD

/-- The positive charge in a generation is `+2`. -/
theorem genPositiveCharge_eq_two : genPositiveCharge = 2 := by
  norm_num [genPositiveCharge, chargeU]

/-- The negative charge in a generation is `−2`. -/
theorem genNegativeCharge_eq_neg_two : genNegativeCharge = -2 := by
  norm_num [genNegativeCharge, chargeE, chargeD]

/-- **The balance is `+2 = −(−2)`, not a trivial `0 = 0`** — the up-type `+2` cancels the
    charged-lepton-plus-down-type `−2`, so the quark thirds are what close the ledger. -/
theorem gen_charge_balanced : genPositiveCharge + genNegativeCharge = 0 := by
  rw [genPositiveCharge_eq_two, genNegativeCharge_eq_neg_two]; norm_num

/-! ### Concrete closures — proton, neutron, hydrogen -/

/-- Proton charge `uud = 2·(2/3) + (−1/3) = +1`. -/
def protonCharge : ℚ := 2 * chargeU + chargeD
/-- Neutron charge `udd = (2/3) + 2·(−1/3) = 0`. -/
def neutronCharge : ℚ := chargeU + 2 * chargeD

theorem proton_charge_one : protonCharge = 1 := by
  norm_num [protonCharge, chargeU, chargeD]

theorem neutron_charge_zero : neutronCharge = 0 := by
  norm_num [neutronCharge, chargeU, chargeD]

/-- **The hydrogen atom is neutral** — `proton (uud) + electron = 0`, the atomic-scale charge
    closure that makes stable matter possible. -/
theorem hydrogen_neutral : protonCharge + chargeE = 0 := by
  rw [proton_charge_one, chargeE]; norm_num

/-! ### Electron capture — what the invariants allow

    `p + e⁻ → n + ν_e` is the `u↔d` gauge-fold pair-flip embedded in a neutral closure
    (`Quarks.md` §4a, `Weak_Force.md` §4b). The four results below establish that the process is
    **allowed by QLF's invariants**: one unit of charge is exactly what the flip costs, exactly one
    quark's flavour moves, the quark count is untouched so the colour knot is not untied, and both
    sides of the reaction are exactly neutral.

    They establish nothing about the **rate**. The weak transition amplitude is the open
    flavour-vertex question (`Quarks.md` §6, `Weak_Force.md` §6), and proving only the invariants is
    how the two are kept apart. -/

/-- A quark flavour in the first-generation weak doublet. -/
inductive Flavour
  | up
  | down
deriving DecidableEq, Repr

/-- The charge of a flavour, from the proven thirds. -/
def flavourCharge : Flavour → ℚ
  | .up   => chargeU
  | .down => chargeD

/-- The charge of a quark content. -/
def chargeOf (qs : List Flavour) : ℚ := (qs.map flavourCharge).sum

/-- The proton's content, `uud`. -/
def protonQuarks : List Flavour := [.up, .up, .down]
/-- The neutron's content, `udd`. -/
def neutronQuarks : List Flavour := [.up, .down, .down]

theorem chargeOf_proton : chargeOf protonQuarks = protonCharge := by
  norm_num [chargeOf, protonQuarks, flavourCharge, protonCharge, chargeU, chargeD]

theorem chargeOf_neutron : chargeOf neutronQuarks = neutronCharge := by
  norm_num [chargeOf, neutronQuarks, flavourCharge, neutronCharge, chargeU, chargeD]

/-- **`u → d` costs exactly one unit of charge**, and the electron supplies exactly that unit.
    Note what this does *not* say: it does not single the electron out. Any `−1` lepton serves, which
    is why **muon capture** (`μ⁻ + p → n + ν_μ`) is the same vertex with a heavier completer —
    see the completing-lepton table in `Weak_Force.md` §4a. -/
theorem up_to_down_one_charge_unit :
    flavourCharge .down - flavourCharge .up = chargeE := by
  norm_num [flavourCharge, chargeU, chargeD, chargeE]

/-- **The local vertex conserves charge** — `u + e⁻ → d + ν`, both sides `−1/3`. Distinguish this
    from the *global* reaction, where both sides are `0`: the embedded vertex is charge-conserving,
    not neutral, and conflating the two is easy to do in a table. -/
theorem local_capture_charge_conserved :
    chargeU + chargeE = chargeD + chargeNu := by
  norm_num [chargeU, chargeD, chargeE, chargeNu]

/-- **Exactly one quark's flavour moves.** The up-count falls by one and the down-count rises by
    one — a single edge, not two, which is what makes this a pair-flip rather than a rearrangement. -/
theorem capture_flips_exactly_one :
    protonQuarks.count .up = neutronQuarks.count .up + 1 ∧
    neutronQuarks.count .down = protonQuarks.count .down + 1 := by
  constructor <;> rfl

/-! #### The colour slots

    The flavour lists above carry no colour information, so a statement about their *length* says
    nothing about colour — `[u,u,d].length = [u,d,d].length` is `3 = 3`, true of any two triples
    whatever. To say something about the knot the nucleon has to be represented as three **colour
    slots** carrying flavour, `Ax → Flavour`, over the same `Ax = {x,y,z}` the baryon winding uses
    (`QLF_BaryonWinding`, and `baryon_needs_all_three_axes` in `QLF_QuarkStructure`).

    Be exact about the division of labour. That every axis stays occupied is true **by construction
    of the representation** — a total function on `Ax` occupies all of `Ax` — so it is a modelling
    choice made explicit, not a discovery. What is then genuinely proved on top of it is that the
    flip moves **exactly one slot** and leaves the other two literally equal. That is the content of
    "changes flavour without untying colour"; the representation supplies the frame, the theorem
    supplies the claim. -/

/-- The proton as three colour slots: `u` on `x`, `u` on `y`, `d` on `z`. -/
def protonSlots : Ax → Flavour
  | .x => .up
  | .y => .up
  | .z => .down

/-- The neutron, the same slots with `y` flipped. -/
def neutronSlots : Ax → Flavour
  | .x => .up
  | .y => .down
  | .z => .down

/-- The charge of a slot assignment. -/
def chargeOfSlots (f : Ax → Flavour) : ℚ :=
  flavourCharge (f .x) + flavourCharge (f .y) + flavourCharge (f .z)

theorem chargeOfSlots_proton : chargeOfSlots protonSlots = protonCharge := by
  norm_num [chargeOfSlots, protonSlots, flavourCharge, protonCharge, chargeU, chargeD]

theorem chargeOfSlots_neutron : chargeOfSlots neutronSlots = neutronCharge := by
  norm_num [chargeOfSlots, neutronSlots, flavourCharge, neutronCharge, chargeU, chargeD]

/-- **Exactly one colour slot changes flavour; the other two are untouched.** The `y` slot goes
    `u → d` and the `x` and `z` slots are literally equal before and after — so the flip rethreads
    flavour through the knot rather than untying it. Contrast deconfinement, where there is no
    slot assignment at all because there is no hadron closure. -/
theorem capture_changes_exactly_one_slot :
    protonSlots Ax.y ≠ neutronSlots Ax.y ∧
    ∀ a : Ax, a ≠ Ax.y → protonSlots a = neutronSlots a := by
  constructor
  · decide
  · intro a ha
    cases a
    · rfl
    · exact absurd rfl ha
    · rfl

/-- **Charge is balanced across the capture** — and not by cancelling something against something,
    but because each side is *separately* neutral: `p + e⁻` is the hydrogen-class closure and
    `n + ν` is the neutron one, two organizations of the same neutral content. -/
theorem electron_capture_charge_balanced :
    protonCharge + chargeE = neutronCharge + chargeNu := by
  rw [proton_charge_one, neutron_charge_zero, chargeE, chargeNu]; norm_num

end QLF
