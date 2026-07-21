import FormalConjecturesUtil

/-!
# A finite certificate for the `k = 4` case of Kourovka Problem 20.71
-/

namespace Kourovka.«20.71»

/-- The vertex-deleted cards of G at u and v are isomorphic. -/
def CardIsoFor {V : Type*} (G : SimpleGraph V) (u v : V) : Prop :=
  Nonempty (G.induce {x | x ≠ u} ≃g G.induce {x | x ≠ v})

/-- The vertices u and v lie in the same orbit of Aut(G). -/
def SameOrbitFor {V : Type*} (G : SimpleGraph V) (u v : V) : Prop :=
  ∃ e : G ≃g G, e u = v

/-- G has exactly k isomorphism types among its vertex-deleted cards. -/
def HasExactlyCardTypes {V : Type*} (G : SimpleGraph V) (k : ℕ) : Prop :=
  ∃ c : V → Fin k, Function.Surjective c ∧
    ∀ u v, CardIsoFor G u v ↔ c u = c v

/-- The action of Aut(G) on vertices has exactly k orbits. -/
def HasExactlyVertexOrbits {V : Type*} (G : SimpleGraph V) (k : ℕ) : Prop :=
  ∃ c : V → Fin k, Function.Surjective c ∧
    ∀ u v, SameOrbitFor G u v ↔ c u = c v

private def edgePairs : List (Nat × Nat) :=
  [(0, 3), (0, 4), (0, 7), (1, 4), (1, 5), (1, 6), (2, 5), (2, 6),
   (2, 7), (2, 8), (3, 6), (3, 7), (3, 8), (4, 8), (5, 7), (6, 8)]

private def adjacent (u v : Fin 9) : Prop :=
  (u.val, v.val) ∈ edgePairs ∨ (v.val, u.val) ∈ edgePairs

private instance adjacentDecidable (u v : Fin 9) : Decidable (adjacent u v) := by
  unfold adjacent
  infer_instance

def witness : SimpleGraph (Fin 9) where
  Adj := adjacent
  symm := by
    intro u v
    rintro (h | h)
    · exact Or.inr h
    · exact Or.inl h
  loopless := by
    intro v
    fin_cases v <;> native_decide

instance (u v : Fin 9) : Decidable (witness.Adj u v) :=
  adjacentDecidable u v

theorem witness_connected : witness.Connected := by
  rw [SimpleGraph.connected_iff_exists_forall_reachable]
  refine ⟨1, ?_⟩
  intro v
  have h14 : witness.Reachable (1 : Fin 9) 4 :=
    SimpleGraph.Adj.reachable (by native_decide)
  have h15 : witness.Reachable (1 : Fin 9) 5 :=
    SimpleGraph.Adj.reachable (by native_decide)
  have h16 : witness.Reachable (1 : Fin 9) 6 :=
    SimpleGraph.Adj.reachable (by native_decide)
  have h40 : witness.Reachable (4 : Fin 9) 0 :=
    SimpleGraph.Adj.reachable (by native_decide)
  have h62 : witness.Reachable (6 : Fin 9) 2 :=
    SimpleGraph.Adj.reachable (by native_decide)
  have h03 : witness.Reachable (0 : Fin 9) 3 :=
    SimpleGraph.Adj.reachable (by native_decide)
  have h07 : witness.Reachable (0 : Fin 9) 7 :=
    SimpleGraph.Adj.reachable (by native_decide)
  have h28 : witness.Reachable (2 : Fin 9) 8 :=
    SimpleGraph.Adj.reachable (by native_decide)
  fin_cases v
  · exact h14.trans h40
  · exact .rfl
  · exact h16.trans h62
  · exact (h14.trans h40).trans h03
  · exact h14
  · exact h15
  · exact h16
  · exact (h14.trans h40).trans h07
  · exact (h16.trans h62).trans h28

def IsAutomorphism (p : Equiv.Perm (Fin 9)) : Prop :=
  ∀ u v, witness.Adj u v ↔ witness.Adj (p u) (p v)

instance (p : Equiv.Perm (Fin 9)) : Decidable (IsAutomorphism p) := by
  unfold IsAutomorphism
  infer_instance

def SameOrbit (u v : Fin 9) : Prop :=
  ∃ p : Equiv.Perm (Fin 9), IsAutomorphism p ∧ p u = v

instance (u v : Fin 9) : Decidable (SameOrbit u v) := by
  unfold SameOrbit
  infer_instance

private def flip : Fin 9 → Fin 9 :=
  ![5, 4, 3, 2, 1, 0, 8, 7, 6]

private theorem flip_involutive : Function.Involutive flip := by
  intro v
  fin_cases v <;> native_decide

private def flipEquiv : Equiv.Perm (Fin 9) :=
  { toFun := flip
    invFun := flip
    left_inv := flip_involutive
    right_inv := flip_involutive }

@[simp] private theorem flipEquiv_apply (v : Fin 9) : flipEquiv v = flip v := rfl

theorem automorphism_classification (p : Equiv.Perm (Fin 9)) :
    IsAutomorphism p ↔ p = Equiv.refl _ ∨ p = flipEquiv := by
  native_decide +revert

private theorem sameOrbit_iff (u v : Fin 9) :
    SameOrbit u v ↔ u = v ∨ flip u = v := by
  constructor
  · rintro ⟨p, hp, hpu⟩
    rcases (automorphism_classification p).mp hp with rfl | rfl
    · exact Or.inl hpu
    · exact Or.inr (by simpa using hpu)
  · rintro (rfl | h)
    · exact ⟨Equiv.refl _, (automorphism_classification _).mpr (Or.inl rfl), rfl⟩
    · exact ⟨flipEquiv, (automorphism_classification _).mpr (Or.inr rfl), by simpa using h⟩

def CardIso (u v : Fin 9) : Prop :=
  ∃ e : {x : Fin 9 // x ≠ u} ≃ {x : Fin 9 // x ≠ v},
    ∀ x y, witness.Adj x.1 y.1 ↔ witness.Adj (e x).1 (e y).1

instance (u v : Fin 9) : Decidable (CardIso u v) := by
  unfold CardIso
  infer_instance

private def orbitClass (v : Fin 9) : Nat :=
  match v.val with
  | 0 | 5 => 0
  | 1 | 4 => 1
  | 2 | 3 => 2
  | 6 | 8 => 3
  | _ => 4

private def cardClass (v : Fin 9) : Nat :=
  match v.val with
  | 0 | 5 => 0
  | 1 | 4 => 1
  | 7 => 3
  | _ => 2

theorem orbit_classification (u v : Fin 9) :
    SameOrbit u v ↔ orbitClass u = orbitClass v := by
  rw [sameOrbit_iff]
  native_decide +revert

theorem card_classification (u v : Fin 9) :
    CardIso u v ↔ cardClass u = cardClass v := by
  native_decide +revert

theorem four_card_types :
    (Finset.univ.image cardClass).card = 4 := by
  native_decide

theorem five_automorphism_orbits :
    (Finset.univ.image orbitClass).card = 5 := by
  native_decide

private def cardClassFin (v : Fin 9) : Fin 4 :=
  ⟨cardClass v, by fin_cases v <;> decide⟩

private def orbitClassFin (v : Fin 9) : Fin 5 :=
  ⟨orbitClass v, by fin_cases v <;> decide⟩

private theorem cardIsoFor_witness_iff (u v : Fin 9) :
    CardIsoFor witness u v ↔ CardIso u v := by
  constructor
  · rintro ⟨e⟩
    exact ⟨e.toEquiv, fun x y => e.map_rel_iff.symm⟩
  · rintro ⟨e, he⟩
    exact ⟨{ toEquiv := e, map_rel_iff' := fun {x y} => (he x y).symm }⟩

private theorem sameOrbitFor_witness_iff (u v : Fin 9) :
    SameOrbitFor witness u v ↔ SameOrbit u v := by
  constructor
  · rintro ⟨e, h⟩
    exact ⟨e.toEquiv, fun x y => e.map_rel_iff.symm, h⟩
  · rintro ⟨p, hp, h⟩
    exact ⟨{ toEquiv := p, map_rel_iff' := fun {x y} => (hp x y).symm }, h⟩

private theorem cardClassFin_surjective : Function.Surjective cardClassFin := by
  native_decide

private theorem orbitClassFin_surjective : Function.Surjective orbitClassFin := by
  native_decide

private theorem cardClassFin_classification (u v : Fin 9) :
    CardIsoFor witness u v ↔ cardClassFin u = cardClassFin v := by
  rw [cardIsoFor_witness_iff, card_classification]
  simp [cardClassFin]

private theorem orbitClassFin_classification (u v : Fin 9) :
    SameOrbitFor witness u v ↔ orbitClassFin u = orbitClassFin v := by
  rw [sameOrbitFor_witness_iff, orbit_classification]
  simp [orbitClassFin]

theorem affirmative_k4 :
    ∃ G : SimpleGraph (Fin 9),
      G.Connected ∧ HasExactlyCardTypes G 4 ∧ HasExactlyVertexOrbits G 5 :=
  ⟨witness, witness_connected,
    ⟨cardClassFin, cardClassFin_surjective, cardClassFin_classification⟩,
    ⟨orbitClassFin, orbitClassFin_surjective, orbitClassFin_classification⟩⟩

end Kourovka.«20.71»
