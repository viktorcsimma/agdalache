.. _backend-tools:

*****
Tools
*****

The Agda SDK comes with some tools (under ``backend/src/Tool/``) to make it easier to write agda2hs-compatible programs and proofs.

Futures are covered in a separate section.

* Cheat.agda contains a postulate called ``cheat`` which can have any type. This way, you can skip proofs by writing ``cheat`` in place of them, then return if you are ready.
* ErasureProduct.agda has some special product types:
  * Σ0 is a sigma-type with a non-erased value in its first field and an erased dependently-typed value in its second field. Such a construction is very useful for existence proofs, as you often need the concrete example, but not the proof that it fulfills the requirements. As agda2hs does not accept non-erased dependently-typed values (since Haskell itself does not support them), this is sometimes the most convenient way to circumvent this problem. You will have to use _:&:_ as the constructor, instead of _,_ for normal sigmas and tuples.
  * Σ' has neither of their fields erased and still allows the second value to have a dependent type. However, the argument of the dependent type should be erased, so that it compiles to a simple type in Haskell::

      record Σ' {i j} (a : Set i) (b : @0 a → Set j) : Set (i ⊔ j)

    This becomes ``Σ' a b`` after compilation.

    The constructor is ``_:^:_``; however, as this sometimes confuses agda2hs when figuring out operator preferences, an alias called ``prefixCon`` is also included.
* Foreign.agda contains conversion functions for C foreign types, as well as the ``stablePtrise`` tool helping to convert AppState manipulations to exportable C functions. See the sections for :ref:`appstate` and the :ref:`api` for more information.
* PropositionalEquality.agda introduces some basic properties of the propositional equality relation ``_≡_``. These can be useful for proofs.
* Relation.agda contains some predicates on relations.
