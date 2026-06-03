# Naming Conventions

All introduced names must use **`snake_case`**. No camelCase, no PascalCase.
This applies to function names, parameter names, local variable names, and member names.

---

## By symbol kind

### Functions

Use a **verb_noun** pattern describing what the function does.

```
collect_metals       ✓
isVowel              ✗  (camelCase)
CollectMetals        ✗  (PascalCase)
```

Good examples from existing renames:
- `collect_metals` — collect resource items into a container
- `toggle_lock` — flip the locked state of a door
- `consume_reagent_and_start_grinding` — two-phase alchemy action
- `apply_birdeye` — apply a birdeye potion effect
- `is_vowel` — predicate returning whether a character is a vowel

### Parameters

Short and contextual. Use the type or role of the value, not a generic `arg1`.

```
item         ✓   (the thing being operated on)
target_mobile ✓  (specific enough to be unambiguous)
i            ✓   (loop index — conventionally fine)
x            ✗   (too vague unless it really is a coordinate)
```

Good examples:
- `container` — an obj parameter holding items
- `type_id` — an int identifying an item type
- `owner` — the character who owns something
- `count` — a numeric quantity

### Local variables

Same rules as parameters. Short, descriptive, scoped to meaning within the function.

```
result       ✓
key_obj      ✓
tmp          ✓   (for truly temporary scratch values)
```

### Members

Use a **noun or noun_phrase** describing what the variable holds — not what it does.

```
reagent_list  ✓
keg_obj       ✓
lock_state    ✓
isLocked      ✗  (camelCase + verb form)
```

---

## Rename key format reminder

When submitting renames, use the correct key format:

- **Function or member**: `script_name.QXXX` → `"blacksmith.Q4S8": "collect_metals"`
- **Local/param**: `script_name.fn_name:QXXX` → `"blacksmith.collect_metals:Q57Q": "container"`

The scoped format uses the **already-renamed** function name in the key, not the original Q-code.

---

## Edge cases

**Single-operation functions** — if a function is so small it does exactly one thing,
a bare verb or noun is fine:
```
"script.Q3XY": "open"      ✓
"script.Q3XY": "do_open"   ✗  (redundant "do_")
```

**Overloaded names across scripts** — the same Q-code may appear in multiple scripts with
different meanings. Always use qualified keys (`script.Q`) to avoid cross-contamination.

**Avoid implementation details** — name what the function *represents*, not how it's coded:
```
"script.Q5AB": "get_lock_owner"       ✓
"script.Q5AB": "read_member_Q3XY"     ✗
```
