# Spacetime and Matter Emergence

A demonstration of how space, time, and matter emerge from logical twist histories in the [Quantum Logical Framework](README.md) (QLF).

**Summary.** Physical entities — the electron, positron, neutrino, photon, and larger bound closures — are strings over the eight basic twists `^ v < > / \ + -`. A string is a *stable particle* when it is a **ZFA closure**: it is **count-balanced** on each axis, and its twist history **folds to a Pauli scalar** (`±I` or `±iI`). Balancing spatial against local free action within these strings is what synthesizes local space and time. All entanglement is internal to the history itself.

The load-bearing correctness condition is the **fold**: the matrix product of the twists must close in the Pauli group. Every example below is checked with `twist_core.py` (`pauli_fold`, `is_pauli_closed`, `is_zfa`) — the same primitives Lean's `count_balanced_pauli_closed` anchors end-to-end.

## Twist → Pauli mapping

The fold uses the canonical axis assignment (`twist_core.py`, `Maxwell.md`):

| Twist | Matrix | | Twist | Matrix | Axis |
|---|---|---|---|---|---|
| `^` | `+σ_y` | | `v` | `−σ_y` | Y |
| `>` | `+σ_x` | | `<` | `−σ_x` | X |
| `/` | `+σ_z` | | `\` | `−σ_z` | Z |
| `+` | `+I`   | | `-` | `−I`   | gauge |

A history folds to `M = M₁·M₂·…·Mₙ` (left to right). It is **Pauli-closed** iff `M ∈ {±I, ±iI}`. A **ZFA closure** additionally requires count balance (`#^=#v`, `#<=#>`, `#/=#\`, `#+=#-`), and the sign of the scalar reads the statistics: `−I` = fermion (an odd number of half-spin folds), `+I` = boson.

## Verified examples

| Particle | Twist history | Fold | Pauli-closed | ZFA |
|---|---|---|---|---|
| **Electron** | `^<v>` | `−I` (fermion) | ✅ | ✅ |
| **Positron** (`e⁺ = ē`, the adjoint) | `<^>v` | `−I` (fermion) | ✅ | ✅ |
| **Muon** (heavier lepton, deeper fold) | `^<v>^<v>^<v>` | `−I` (fermion) | ✅ | ✅ |
| **Neutrino** (Majorana) | `^-v+` | `+I` | ✅ | ✅ |
| **Composite closure** (two folds + charge lines `+-`) | `^<v>^<v>+-` | `−I` | ✅ | ✅ |
| **Photon** (propagating) | `^^^^<<<<////` | `+I` | ✅ | ❌ |

Notes:

- **Electron `^<v>` → −I.** The minimal fermion closure — up · left · down · right. This is exactly Lean's `fold_electron` / `fold_uldr` (`QLF_PhaseInformation`). Its count is balanced on the Y and X axes; the fold is `−I`.
- **Positron `<^>v`.** The antiparticle is the adjoint (Hermitian conjugate = conjugate-and-reverse, `adjoint_history`) of the electron; it carries the same `−I` fermion signature (`QLF_Majorana`, `QLF_Spin`).
- **Muon.** A heavier lepton is a *deeper* fold with the same fermion signature — an odd stack of electron folds still lands on `−I`. QLF does not yet fix the exact muon string; this is a signature-correct illustration, not a mass derivation (`m = 1/R`, deeper = heavier).
- **Neutrino `^-v+` → +I.** A balanced closure on the Y and gauge axes; the neutrino is its own antiparticle (Majorana, `QLF_Majorana`).
- **Photon `^^^^<<<<////` → +I but NOT count-balanced.** Each axis appears four times with one sign, so the fold still closes (`(±σ)⁴ = I`) — it is **Pauli-closed but not count-balanced**, which is precisely a *propagating, massless* mode rather than a stable rest closure. This is why it is labeled wave-like, not particle-like.

The previous version of this document listed the electron as `^>v<^+/-`. **That string is not a closure** — it folds to `iσ_x`, which is *not* a Pauli scalar (`is_pauli_closed` returns `False`) — so it cannot be a stable particle. The strings above are the corrected, verified assignments.

## Reproduce

```python
from twist_core import pauli_fold, is_pauli_closed, is_zfa
from spacetime_dynamics import SpacetimeGenerator

for name, h in [
    ("Electron",  "^<v>"),
    ("Positron",  "<^>v"),
    ("Muon",      "^<v>^<v>^<v>"),
    ("Neutrino",  "^-v+"),
    ("Composite", "^<v>^<v>+-"),
    ("Photon",    "^^^^<<<<////"),
]:
    print(name, h,
          "fold=", pauli_fold(h),
          "closed=", is_pauli_closed(h),
          "zfa=", is_zfa(h))

# Emergent bookkeeping for one closure:
g = SpacetimeGenerator("^<v>^<v>+-")
for k, v in g.model_spacetime().items():
    print(f"  {k}: {v}")
```

Space emerges from the spatial free action, time from the local free action (`f = 1/t`); a fully balanced rest closure leaks no local free action (`t → ∞`, `f → 0`), while the propagating photon carries nonzero spatial free action.

![particles 2006](Particles.jpg)
