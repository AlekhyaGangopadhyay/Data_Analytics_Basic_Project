# Relational Data Model, SQL & Integrity Constraints — Enhanced Study Guide

**Syllabus coverage:** Structure of Relational Databases, Relational Algebra Operations [2L] • Relational Calculus [2L] • Extended Relational Algebra Operations, Views, Modification of the Database [2L] • Database Languages — DDL, DML, DCL [1L] • Basic SQL Structure, Set Operations, Aggregate Functions, Null Values [2L] • Domain & Referential Integrity Constraints, Assertions, Views [2L] • Joins [1L] • Nested Subqueries [1L] • Stored Procedures, Triggers, Overview of Query Optimization [1L]

Each lecture block below includes detailed notes, worked examples, comparison tables, tricky-question traps, and a question bank (short answer, long answer, conceptual traps) to prepare for both theory exams and viva.

---

## LECTURE 1: Structure of Relational Databases & Relational Algebra Operations

### 1.1 Formal Structure of the Relational Model

> **Relation Schema:** Denoted $R(A_1, A_2, ..., A_n)$ — a relation name $R$ together with a list of attributes $A_1$ through $A_n$. Example: `STUDENT(Roll_no, Name, Dept, GPA)`.
>
> **Relation (Relation State/Instance):** A set of $n$-tuples $r(R) = \{t_1, t_2, ..., t_m\}$, i.e., the actual data currently held, viewed as a *mathematical set*. Because it is a true set, **no two tuples in a relation state can be identical**, and (in the pure model) **there is no defined order among tuples**.
>
> **Tuple:** An ordered list of $n$ values $t = \langle v_1, v_2, ..., v_n \rangle$, one value per attribute, corresponding to a single record/row.
>
> **Domain, $dom(A)$:** The set of atomic (indivisible), permitted values for attribute $A$. Example: `dom(GPA) = {x ∈ real | 0.0 ≤ x ≤ 10.0}`.
>
> **Degree of a relation:** The number of attributes $n$ in its schema. **Cardinality:** The number of tuples currently in the relation state (changes constantly, unlike degree).

**Worked Example:**

`STUDENT(Roll_no, Name, Dept, GPA)` — degree = 4.

| Roll_no | Name | Dept | GPA |
|---|---|---|---|
| 101 | Ana | CS | 8.9 |
| 102 | Ravi | EE | 7.4 |
| 103 | Sam | CS | 9.1 |

Cardinality of this state = 3.

> **Tricky question:** "If we insert a new student, does the relation's *degree* change?" → **No.** Degree (number of attributes) is a schema-level property and stays fixed unless the schema itself is altered (e.g., via `ALTER TABLE`). Only **cardinality** (row count) changes with data operations.

### 1.2 Relational Model Constraints (Quick Reference — detailed later)

| Constraint | One-line rule |
|---|---|
| Domain Constraint | Every attribute value must come from its declared domain |
| Key Constraint | No two tuples can have the same combination of values for a key |
| Entity Integrity | No primary key attribute can be NULL |
| Referential Integrity | A foreign key value must either match an existing referenced primary key or be NULL |

### 1.3 Relational Algebra — Overview

> **Definition:** Relational Algebra is a **procedural** query language: a set of operations that take one or two relations as input and produce a new relation as output. Because the output of every operation is itself a relation, operations can be **nested/composed** — this is called **closure**.

**Why "procedural"?** The user (or optimizer) specifies a *sequence of operations* — i.e., *how* to derive the result — as opposed to relational calculus/SQL, which is largely *declarative* (*what* result is wanted).

### 1.4 Unary Operations

#### SELECT ($\sigma$) — Horizontal Subsetting

$$\sigma_{\text{condition}}(R)$$

Chooses a subset of the tuples from $R$ that satisfy a selection condition — think "filter rows."

**Example:** Retrieve all employees in department 5 earning more than 30000:
$$\sigma_{Dno=5 \; \text{AND} \; Salary > 30000}(EMPLOYEE)$$

**Properties:**
- **Commutative:** $\sigma_{c1}(\sigma_{c2}(R)) = \sigma_{c2}(\sigma_{c1}(R))$
- A cascade of SELECTs can be combined into a single SELECT with an AND of all conditions: $\sigma_{c1}(\sigma_{c2}(R)) = \sigma_{c1 \, \text{AND} \, c2}(R)$.
- **Result degree** = degree of $R$ (all attributes kept); **result cardinality ≤** cardinality of $R$.

#### PROJECT ($\pi$) — Vertical Subsetting

$$\pi_{\text{attribute-list}}(R)$$

Selects certain **columns** and discards the rest, then **removes duplicate tuples** (because relational algebra results are formal sets).

**Example:** List only names and salaries of all employees:
$$\pi_{Name, Salary}(EMPLOYEE)$$

> **Tricky question:** "Is PROJECT commutative like SELECT?" → **No** — $\pi_{list1}(\pi_{list2}(R))$ is only valid if `list1` is a subset of `list2`; unlike SELECT, PROJECT's order matters/its composition is restricted.
>
> **Tricky question:** "Why does PROJECT sometimes reduce cardinality even though SELECT doesn't add rows?" → Because dropping columns can make previously-distinct tuples identical, and duplicates are eliminated from the resulting set (e.g., projecting only `Dept` from EMPLOYEE collapses all employees in the same department into a single row).

#### RENAME ($\rho$)

$$\rho_{S(B_1, ..., B_n)}(R)$$

Renames the relation (to $S$) and/or its attributes (to $B_1, ..., B_n$). Essential for:
- **Self-joins** (referencing the same relation twice under different names).
- Resolving ambiguous attribute names after a Cartesian product/join of relations that share an attribute name.

### 1.5 Set Theoretic Operations

These require **Union Compatibility**: two relations $R$ and $S$ are union-compatible if they have the **same degree** (number of attributes) and the domain of each corresponding attribute is the same.

| Operation | Symbol | Meaning | Union-Compatible Required? |
|---|---|---|---|
| Union | $R \cup S$ | Tuples in $R$, or $S$, or both (duplicates eliminated) | Yes |
| Intersection | $R \cap S$ | Tuples in **both** $R$ and $S$ | Yes |
| Set Difference | $R - S$ | Tuples in $R$ but **not** in $S$ | Yes |
| Cartesian Product | $R \times S$ | Every combination of a tuple from $R$ with a tuple from $S$ | **Not required** |

**Worked example:** `SSN_of_smiths ← π_Ssn(σ_Lname='Smith'(EMPLOYEE))`, and suppose we also compute `SSN_of_managers`. Then:
- $SSN\_of\_smiths \cup SSN\_of\_managers$ = SSNs of people who are Smiths **or** managers.
- $SSN\_of\_smiths \cap SSN\_of\_managers$ = SSNs of people who are **both** Smiths and managers.
- $SSN\_of\_smiths - SSN\_of\_managers$ = SSNs of Smiths who are **not** managers.

#### CARTESIAN PRODUCT ($\times$)

$$R \times S$$ produces a relation of degree $= deg(R) + deg(S)$, with cardinality $= |R| \times |S|$.

> **"So What?" of Cartesian Products in real systems:** A Cartesian product with no accompanying join condition, run against multi-million-row tables, produces an **$N \times M$** result — this explodes memory/buffer usage, saturates transaction logs (if materialized), and can cause the query engine to hang. In practice, an *accidental* Cartesian product (a forgotten `WHERE` join condition in old-style SQL joins) is one of the most common real-world query-writing bugs.

**Tricky question:** "Is Cartesian Product commutative?" → In terms of the **set of tuples produced**, yes (order of attributes may differ, but the same *information* results); in terms of literal attribute ordering, $R \times S \neq S \times R$ strictly, though this distinction is rarely tested beyond noting attribute order changes.

### 1.6 Question Bank — Lecture 1

**Short Answer:**
1. Define relation schema, relation state, tuple, and domain.
2. Differentiate between degree and cardinality of a relation.
3. Why must PROJECT eliminate duplicate tuples but SELECT does not?
4. State the union compatibility condition with an example of two union-compatible relations.
5. What is the "closure property" of relational algebra, and why is it significant?

**Long Answer:**
1. Given `EMPLOYEE(Ssn, Name, Salary, Dno)`, write relational algebra expressions for: (a) all employees in department 4, (b) only names and salaries of all employees, (c) names of employees earning more than 50000 in department 4.
2. Explain why an unchecked Cartesian Product is dangerous in production systems, with a description of the resource exhaustion chain it triggers.
3. Explain the RENAME operation's necessity using a self-join scenario (e.g., EMPLOYEE supervises EMPLOYEE).

**Tricky / Conceptual Traps:**
1. "Relational Algebra results are always sets, so duplicates never appear in any intermediate step." → **False** — duplicates can appear transiently, but final PROJECT-style operations remove them; note that SQL itself (unlike pure algebra) is bag-based and *does* allow duplicates unless DISTINCT is applied (see Lecture 4).
2. "SELECT changes the degree of a relation." → **False**, SELECT only filters rows (cardinality may shrink), degree is unchanged. PROJECT is the operation that changes degree.
3. Why is $\pi_{Dept}(EMPLOYEE)$ likely to have far fewer tuples than $EMPLOYEE$ itself?

---

## LECTURE 2: Relational Calculus — Operations, Examples, and Exercises

### 2.1 Algebra vs. Calculus — The Core Philosophical Divide

| Aspect | Relational Algebra | Relational Calculus |
|---|---|---|
| Paradigm | **Procedural** | **Declarative (non-procedural)** |
| Specifies | *How* to retrieve the data (sequence of operations) | *What* data is wanted (a formula the data must satisfy) |
| Core building block | Operators (σ, π, ⋈, ∪, ...) | Variables + Predicate logic (∃, ∀, ∧, ∨, ¬) |
| Expressive power | Equivalent to "safe" relational calculus | Equivalent to relational algebra (Codd's theorem) |

> **Codd's Theorem (frequently tested):** Relational Algebra and *safe* Relational Calculus have **equivalent expressive power** — any query expressible in one can be expressed in the other. A language with this expressive power is said to be **relationally complete**.

### 2.2 Tuple Relational Calculus (TRC)

> **Definition:** A query in TRC is expressed as: $$\{t \mid COND(t)\}$$ — "the set of all tuples $t$ such that condition $COND(t)$ is true," where $t$ is a **tuple variable** ranging over a named relation.

**Quantifiers:**
- $\exists t (COND(t))$ — "**there exists** a tuple $t$ such that COND(t) is true" (existential quantifier).
- $(\forall t)(COND(t))$ — "**for all** tuples $t$, COND(t) is true" (universal quantifier).

**Worked Example:** Retrieve the name and address of employees who work for the 'Research' department:

$$\{ t.Fname, t.Lname, t.Address \mid EMPLOYEE(t) \; \text{AND} \; (\exists d)(DEPARTMENT(d) \; \text{AND} \; d.Dname='Research' \; \text{AND} \; d.Dnumber = t.Dno) \}$$

**Key trick — converting $\forall$ into $\exists$ using De Morgan's-style equivalence** (very commonly tested):

$$(\forall t)(COND(t)) \equiv \neg (\exists t) (\neg COND(t))$$

This is essential because many query engines/proofs prefer working purely with $\exists$. Typical use case: "Find employees who work on **all** projects controlled by department 5" is naturally a $\forall$-statement, and is often rewritten via a nested $\neg \exists (\neg ...)$ formulation.

> **Tricky question:** "Are all TRC formulas 'safe' (guaranteed to produce a finite result)?" → **No.** A formula like $\{t \mid \neg EMPLOYEE(t)\}$ is *unsafe* because it could range over an infinite domain of tuples not in EMPLOYEE. The concept of **safety of expression** restricts formulas to those that only yield answers drawn from the finite domain of values actually appearing in the database (or explicitly mentioned in the query).

### 2.3 Domain Relational Calculus (DRC)

> **Definition:** DRC differs from TRC in that variables range over single **attribute domain values**, not entire tuples. A query has the general form: $$\{ x_1, x_2, ..., x_n \mid COND(x_1, x_2, ..., x_n) \}$$ where each $x_i$ is a **domain variable**.

**Worked Example:** Retrieve the birthdate and address of 'John Smith':

$$\{uv \mid (\exists q)(\exists r)(\exists s)(\exists t)(\exists w)(\exists x)(\exists y)(\exists z) \\ (EMPLOYEE(qrstuvwxyz) \; \text{AND} \; q = \text{'John'} \; \text{AND} \; r = \text{'Smith'} \; \text{AND} \; u=\text{Bdate} \; \text{AND} \; v=\text{Address})\}$$

*(In practice, DRC is presented more compactly with named domain variables per attribute, e.g., `Fname`, `Lname`, `Bdate`, `Address` directly, rather than positional dummies — the positional form above illustrates the formal definition.)*

#### Query-By-Example (QBE)

> **Definition:** QBE is a **visual/graphical implementation of Domain Relational Calculus**. Users fill in **skeleton tables** with example rows using:
> - A **P.** (print) operator to indicate which columns to display in the result.
> - **Condition boxes** for complex logic that doesn't fit directly in the table cells.

**Why it matters:** QBE demonstrates that DRC's domain-variable-based approach maps naturally onto a spreadsheet-like, non-programmer-friendly interface — this is the classic exam link between DRC (theory) and QBE (practical realization).

### 2.4 TRC vs. DRC — Side-by-Side

| Aspect | Tuple Relational Calculus (TRC) | Domain Relational Calculus (DRC) |
|---|---|---|
| Variable ranges over | Entire tuples | Individual attribute domain values |
| Example System | Original SQL heritage (SQL is loosely based on TRC concepts, though implemented as a bag-language) | QBE |
| Notation | $\{t \mid COND(t)\}$ | $\{x_1,...,x_n \mid COND(x_1,...,x_n)\}$ |

### 2.5 Question Bank — Lecture 2

**Short Answer:**
1. Differentiate between Relational Algebra and Relational Calculus.
2. State Codd's theorem regarding expressive power.
3. Define "safety of expression" in relational calculus with an example of an unsafe query.
4. What is the difference between TRC and DRC?
5. What does QBE stand for, and which calculus does it implement?

**Long Answer:**
1. Write a TRC query to "retrieve the names of employees who work on all projects controlled by department number 5," explaining your use of ∀ (or its ¬∃¬ equivalent).
2. Explain, with an example, why $(\forall t)(COND(t))$ is often rewritten as $\neg(\exists t)(\neg COND(t))$ in query processing.
3. Compare and contrast how the same query ("find employees in the Research department") would be expressed in Relational Algebra vs. TRC.

**Tricky / Conceptual Traps:**
1. "Since SQL retrieval is declarative, SQL is a direct implementation of Domain Relational Calculus." → **Partially misleading** — SQL borrows conceptually from both algebra and calculus and is technically closer in spirit to tuple-oriented thinking, but SQL is its own bag-based language, not a strict formal implementation of either.
2. "Every syntactically valid calculus formula is guaranteed to produce a finite, correct answer." → **False** — only *safe* expressions guarantee this; unsafe expressions can imply infinite result sets.
3. Why can't relational calculus, as commonly taught, express aggregate functions like SUM or COUNT directly? (These require **extensions beyond first-order predicate logic** — this is exactly why Extended Relational Algebra introduces a separate aggregate operator, covered next.)

---

## LECTURE 3: Extended Relational Algebra, Views, and Modification of the Database

### 3.1 Why "Extend" the Algebra?

Pure relational algebra (SELECT, PROJECT, JOIN, set operations) cannot express **aggregate summaries** (e.g., "average salary per department") or **explicit ordering**. Extended operations fill this gap.

### 3.2 Aggregate Functions

> **Notation:** $$_{\;GroupingAttributes}\mathcal{F}_{\;function\_list}(R)$$ using the calligraphic $\mathcal{F}$.

**Standard functions:** `SUM`, `AVG`, `MIN`, `MAX`, `COUNT`.

**Worked Example:** Average salary grouped by department number:

$$_{DNO}\mathcal{F}_{AVG(Salary)}(EMPLOYEE)$$

Result: one row per distinct `DNO`, with the average salary for that department.

**Without a grouping attribute**, the function applies to the *entire* relation as one group:

$$\mathcal{F}_{COUNT(Ssn)}(EMPLOYEE)$$

Result: a single value — total employee count.

> **Tricky question:** "If GROUP BY is omitted in SQL but an aggregate function is used alongside a non-aggregated column, what happens?" → This is a **semantic error** in standard SQL (mixing grouped and non-grouped columns without a GROUP BY) — most RDBMSs will reject the query or (in lenient/legacy modes) return an arbitrary value for the non-aggregated column, which is why it's considered bad practice/an error.

### 3.3 Recursive Closure & Self-Referencing Relationships

For hierarchical/recursive relationships (e.g., `EMPLOYEE.Superssn` referencing `EMPLOYEE.Ssn`), relational algebra traditionally struggles because a fixed number of joins can only traverse a fixed number of hierarchy levels. This is handled via:
- **Aliasing (RENAME)** the same relation as two logical roles for a single level (e.g., "the employee" vs. "the supervisor").
- **Recursive closure operations** (an advanced extension, not part of basic relational algebra) for arbitrary-depth hierarchies (e.g., "find all employees, at any level, who ultimately report to the CEO").

**Production SQL Syntax for one-level self-join (Query 8 style):**

```sql
SELECT E.FNAME, E.LNAME, S.FNAME, S.LNAME
FROM EMPLOYEE AS E, EMPLOYEE AS S
WHERE E.SUPERSSN = S.SSN;
```

Here `E` and `S` are two aliases of the *same* physical table, treated as logically distinct relations — this is precisely why RENAME ($\rho$) is indispensable in the algebra.

### 3.4 Views — Virtual Tables

> **Definition:** A **View** is a *virtual* (derived) relation, defined by a query over one or more base tables, that does **not** store data physically — it is (re)computed (or maintained incrementally) whenever referenced.

**Syntax:**

```sql
CREATE VIEW WORKS_ON1 AS
SELECT E.FNAME, E.LNAME, P.PNAME, W.HOURS
FROM EMPLOYEE E, PROJECT P, WORKS_ON W
WHERE E.SSN = W.ESSN AND P.PNUMBER = W.PNO;
```

**Purposes of Views:**
1. **Security:** Expose only relevant columns/rows to a class of users (e.g., hide `Salary` from a general view of `EMPLOYEE`).
2. **Simplification:** Package a complex multi-table join into a simple, reusable "table-like" object.
3. **Logical Data Independence:** Insulate applications from certain schema changes at the base-table level.

**View Materialization strategies (implementation detail sometimes tested):**
- **Query Modification:** The view query is substituted into the user's query at run time (can be inefficient for complex views).
- **View Materialization:** The view's result is physically computed once and cached; must be kept in sync with base tables via **incremental update** algorithms when base data changes.

#### View Updatability — A High-Yield Exam Point

| View Type | Updatable? |
|---|---|
| Simple view on a single table, includes the table's primary key | Generally **yes** |
| View with a JOIN across multiple tables | Generally **no** |
| View with GROUP BY / aggregate functions | **No** |
| View with DISTINCT | Generally **no** |

> **Tricky question:** "Why can't a view involving a JOIN be updated?" → Because an `INSERT`/`UPDATE` on the view would require the DBMS to **unambiguously decide which base table(s)** the new/changed values belong to — a join can combine columns from multiple tables in ways that don't map back cleanly to a single-table modification.

### 3.5 Modification of the Database — Insert, Delete, Update in Relational Algebra Terms

Although INSERT/DELETE/UPDATE are typically taught as SQL DML statements, at the relational-model level they are **database state transformations** that must preserve all constraints (domain, key, entity integrity, referential integrity).

| Operation | Constraint Checks Required |
|---|---|
| **INSERT** | Domain (values match types), Key (no duplicate PK), Entity Integrity (PK not null), Referential Integrity (FK values must exist in referenced table or be null) |
| **DELETE** | Referential Integrity (does any other tuple reference this one via FK?) |
| **UPDATE** | Any of the above, depending on which attribute is modified — updating a PK or FK is especially constraint-sensitive |

### 3.6 Question Bank — Lecture 3

**Short Answer:**
1. Write the aggregate function notation to count the number of employees in each department.
2. Define a View. Name two purposes it serves.
3. Under what conditions is a view generally NOT updatable?
4. Why is RENAME essential for representing recursive/self-referencing relationships in algebra?

**Long Answer:**
1. Explain, with syntax, how a view is created and how "query modification" vs. "view materialization" differ as implementation strategies, including the trade-offs of each.
2. Using `EMPLOYEE(Ssn, Name, Salary, Dno, Superssn)`, write the SQL and describe the relational algebra equivalent for retrieving each employee's name alongside their supervisor's name.
3. Explain how INSERT, DELETE, and UPDATE operations must each be checked against the model's integrity constraints, with one example violation for each operation.

**Tricky / Conceptual Traps:**
1. "A view, once created, always reflects the very latest data in the base tables." → **Only true under query modification** or automatically-refreshed materialized views; a *stale* materialized view (if refresh is deferred/manual) can lag behind the base tables.
2. "Aggregate functions are part of the base relational algebra defined by Codd." → **False** — they are part of the *extended* algebra, since first-order predicate logic (and the base algebra derived from it) cannot express numeric summarization directly.
3. Can a view be built on top of another view? (**Yes** — views can be nested/stacked, though this can compound update-restriction issues and performance overhead.)

---

## LECTURE 4: Concept of Database Languages — DDL, DML, DCL

### 4.1 The Three (or Four) Sub-Languages

| Language | Full Form | Purpose | Example Statements |
|---|---|---|---|
| **DDL** | Data Definition Language | Define/modify schema structure | `CREATE TABLE`, `ALTER TABLE`, `DROP TABLE`, `CREATE SCHEMA`, `CREATE VIEW` |
| **DML** | Data Manipulation Language | Insert/retrieve/update/delete data | `SELECT`, `INSERT`, `UPDATE`, `DELETE` |
| **DCL** | Data Control Language | Manage access rights/permissions | `GRANT`, `REVOKE` |
| **TCL** *(often grouped with DCL)* | Transaction Control Language | Manage transaction boundaries | `COMMIT`, `ROLLBACK`, `SAVEPOINT` |

> **Tricky exam distinction:** Is `SELECT` a DDL, DML, or DCL statement? → **DML** — even though it doesn't modify data, it is classified as data *manipulation* (specifically, *retrieval*), the read-side of DML.

### 4.2 DDL in Detail

- **CREATE SCHEMA:** Establishes a named database container and specifies its owner/authorization identifier.
- **CREATE TABLE:** Defines a base relation — its attributes, data types, and constraints (PK, FK, NOT NULL, CHECK, etc.).
- **DROP TABLE:** Permanently removes a relation and its metadata/catalog entry (irreversible without backup).
- **ALTER TABLE:** Evolves an existing schema, most commonly to `ADD` a new column, `DROP` a column, or modify constraints.

> **Tricky rule (frequently tested):** When you `ALTER TABLE ... ADD` a new column, you **cannot** simultaneously mark it `NOT NULL` if the table already has existing rows — because the RDBMS must populate the new column with `NULL` for all pre-existing tuples first. Only after a subsequent `UPDATE` fills in real values for every row can a `NOT NULL` constraint be validly applied (via a further `ALTER TABLE ... MODIFY`/`ALTER COLUMN`, syntax varies by RDBMS).

### 4.3 DML in Detail

| Statement | Purpose | Constraint Sensitivity |
|---|---|---|
| `INSERT` | Add new tuple(s) | Domain, Key, Entity Integrity, Referential Integrity |
| `DELETE` | Remove tuple(s) matching a condition | Referential Integrity (cascading effects) |
| `UPDATE` | Modify existing attribute value(s) | Any constraint, depending on the attribute changed |
| `SELECT` | Retrieve data (read-only) | None (no state change) |

### 4.4 DCL in Detail

```sql
GRANT SELECT, INSERT ON EMPLOYEE TO clerk_user;
REVOKE INSERT ON EMPLOYEE FROM clerk_user;
```

- **GRANT:** Confers specific privileges (SELECT, INSERT, UPDATE, DELETE, etc.) on database objects to specific users/roles.
- **REVOKE:** Withdraws previously granted privileges.

### 4.5 Question Bank — Lecture 4

**Short Answer:**
1. Classify each of the following as DDL, DML, or DCL: `CREATE TABLE`, `SELECT`, `GRANT`, `DELETE`, `ALTER TABLE`, `REVOKE`.
2. Why can't a NOT NULL constraint be added directly along with a new column via ALTER TABLE on a populated table?
3. What's the difference between DROP TABLE and DELETE (from a table)?

**Long Answer:**
1. Explain the full lifecycle of a table — from `CREATE TABLE` through several `ALTER TABLE` operations to eventual `DROP TABLE` — identifying which DDL command is used at each stage and any constraint caveats.
2. Discuss why access control (DCL) is essential in a multi-user enterprise DBMS, with an example GRANT/REVOKE scenario for a "read-only auditor" role.

**Tricky / Conceptual Traps:**
1. "DROP TABLE and DELETE FROM table (with no WHERE clause) have the same effect." → **False** — `DELETE` (a DML operation) removes all rows but the empty table and its schema/metadata still exist; `DROP TABLE` (a DDL operation) removes the table structure and catalog entry entirely.
2. "GRANT and REVOKE are DML statements since they affect what a user can 'manipulate.'" → **False** — they are DCL, governing *permissions*, not data manipulation.

---

## LECTURE 5: Basic SQL Structure, Set Operations, Aggregate Functions, and Null Values

### 5.1 SQL Is Bag-Based, Not Set-Based

> Unlike pure relational algebra (which operates on mathematical **sets** — no duplicates), SQL by default operates on **bags (multisets)** — duplicates are permitted unless explicitly removed.

**Example:** `{A, B, A}` as a bag is distinct from the set `{A, B}` — SQL's default `SELECT` behaves like the bag `{A, B, A}` unless `DISTINCT` is specified.

> **"So What?" of bag logic:** Using `DISTINCT` forces the engine to perform a **sort/hash-based duplicate-elimination pass**, which is computationally expensive on large result sets. Architects apply `DISTINCT` only when duplicates would produce a semantically wrong (not just aesthetically redundant) answer — e.g., counting *distinct* departments that have at least one employee, versus counting all employee-department pairings.

### 5.2 Basic SQL Query Structure

```sql
SELECT <attribute list>
FROM <table list>
WHERE <condition>
GROUP BY <grouping attributes>
HAVING <group condition>
ORDER BY <sort attributes>;
```

#### Logical (Internal) Execution Order — a High-Yield Exam Topic

| Step | Clause | What Happens |
|---|---|---|
| 1 | **FROM** | Identify source table(s); perform any joins/Cartesian products |
| 2 | **WHERE** | Filter individual tuples (row-level condition, cannot use aggregate functions here) |
| 3 | **GROUP BY** | Partition remaining tuples into groups sharing common values |
| 4 | **HAVING** | Filter *entire groups* (can use aggregate functions here) |
| 5 | **SELECT** | Project final attributes/expressions |
| 6 | **ORDER BY** | Sort the final result set |

> **Tricky question:** "Why can't I use a column alias (defined in SELECT) inside the WHERE clause?" → Because **WHERE is logically evaluated before SELECT** in the internal execution order — the alias doesn't exist yet when WHERE is processed. (Some RDBMSs allow aliases in `GROUP BY`/`ORDER BY` as an extension, since those execute after or alongside SELECT, but `WHERE` strictly cannot use them.)
>
> **Tricky question:** "Can I filter on an aggregate function's result in the WHERE clause?" → **No** — aggregate filters must go in `HAVING`, because aggregates are computed *after* grouping, which happens after `WHERE`.

### 5.3 Set Operations in SQL

| Operation | SQL Keyword | Duplicate Behavior |
|---|---|---|
| Union | `UNION` | Removes duplicates by default; `UNION ALL` keeps them |
| Intersection | `INTERSECT` | Removes duplicates by default; `INTERSECT ALL` keeps matched duplicates |
| Difference | `EXCEPT` (or `MINUS` in Oracle) | Removes duplicates by default |

> **Tricky question:** "Does plain SQL `UNION` behave like a bag or a set operation?" → **Set** — `UNION` (without `ALL`) explicitly removes duplicates, unlike SQL's normal bag-based default; this is one of the few places SQL reverts to pure set semantics unless you override it with `ALL`.

### 5.4 Aggregate Functions in SQL

| Function | Description | Handles NULL? |
|---|---|---|
| `COUNT(*)` | Counts all rows, including rows with NULLs anywhere | N/A (counts rows, not values) |
| `COUNT(column)` | Counts non-NULL values in that column | **Ignores NULLs** |
| `SUM`, `AVG`, `MIN`, `MAX` | Aggregate a numeric/comparable column | **Ignores NULLs** in the computation |

**Worked Example:**

```sql
SELECT DNO, AVG(SALARY)
FROM EMPLOYEE
GROUP BY DNO
HAVING COUNT(*) > 5;
```

Retrieves the average salary for each department, but only for departments having more than 5 employees.

> **Tricky question:** "If a `Salary` column has some NULL values, does `AVG(Salary)` divide by the total row count or the count of non-null salaries?" → It divides by the **count of non-NULL salary values only** — NULLs are excluded entirely from both the sum and the divisor, which can surprise those expecting NULL to be treated as zero.

### 5.5 NULL Values — Three-Valued Logic

> NULL represents an **unknown, missing, or not-applicable** value — it is *not* the same as zero or an empty string.

SQL uses **three-valued logic**: `TRUE`, `FALSE`, and `UNKNOWN`.

| Expression | Result |
|---|---|
| `NULL = NULL` | `UNKNOWN` (not TRUE!) |
| `NULL <> NULL` | `UNKNOWN` |
| `5 > NULL` | `UNKNOWN` |
| `TRUE AND UNKNOWN` | `UNKNOWN` |
| `FALSE AND UNKNOWN` | `FALSE` |
| `TRUE OR UNKNOWN` | `TRUE` |

**Testing for NULL:** Must use `IS NULL` / `IS NOT NULL` — **never** `= NULL`.

> **Tricky question (extremely common exam trap):** "Why does `WHERE Salary = NULL` return zero rows even for rows where Salary is genuinely NULL?" → Because `NULL = NULL` evaluates to `UNKNOWN`, not `TRUE`, and `WHERE` only keeps rows where the condition evaluates to `TRUE` (rows evaluating to `UNKNOWN` or `FALSE` are both excluded). You must use `WHERE Salary IS NULL`.

### 5.6 Question Bank — Lecture 5

**Short Answer:**
1. Why is SQL called "bag-based" rather than "set-based"? Give an example.
2. List the logical order of execution of SQL clauses.
3. Differentiate between `COUNT(*)` and `COUNT(column_name)`.
4. What does `UNKNOWN` mean in SQL's three-valued logic, and when does it arise?
5. Why must `IS NULL` be used instead of `= NULL`?

**Long Answer:**
1. Explain, with a query example, why aggregate functions cannot be used directly in a WHERE clause, and how HAVING solves this.
2. Discuss the behavior of NULL under three-valued logic across AND, OR, and NOT operators, with a full truth table.
3. Write a query to find departments with more than 3 employees and an average salary above 40000, explaining every clause's role.

**Tricky / Conceptual Traps:**
1. "`UNION ALL` is slower than `UNION` because ALL implies extra processing." → **False** — it's the opposite: `UNION` is slower because it must perform duplicate elimination (a sort/hash step); `UNION ALL` skips this and is generally faster.
2. "If a column has NULL for every row, `COUNT(column)` still returns the number of rows." → **False** — `COUNT(column)` returns **0** in this case, since it ignores NULLs entirely, whereas `COUNT(*)` would return the actual row count.
3. Does `NOT (NULL)` evaluate to `NULL`/`UNKNOWN` or to a definite `TRUE`/`FALSE`? (→ `UNKNOWN`, consistent with three-valued logic.)

---

## LECTURE 6: Domain & Referential Integrity Constraints, Assertions, Views

### 6.1 The Three (Four) Pillars of Integrity — Recap and Deep Dive

| Constraint | Rule | Violation Example |
|---|---|---|
| **Domain Constraint** | Every attribute's value must be from its declared domain (correct data type, format, range) | Inserting the string `"abc"` into an `INTEGER` column |
| **Key Constraint** | No two tuples can agree on all key attribute values | Inserting a second employee with the same `Ssn` |
| **Entity Integrity** | No component of any primary key can be NULL | `INSERT INTO EMPLOYEE(Ssn, Name) VALUES (NULL, 'Ana')` |
| **Referential Integrity** | Every non-null foreign key value must match an existing primary key value in the referenced relation | Inserting an employee with `Dno = 99` when no department 99 exists |

### 6.2 Referential Integrity — Referential Actions in Depth

When the *referenced* tuple (the "parent," holding the primary key) is deleted or its key is updated, the DBMS must decide what happens to *referencing* tuples (the "children," holding the foreign key).

| Action | Effect on DELETE of parent | Effect on UPDATE of parent's key |
|---|---|---|
| **RESTRICT / NO ACTION (REJECT)** | Deletion is **blocked** if any child references it | Update is **blocked** if any child references it |
| **CASCADE** | All referencing child tuples are **also deleted** | All referencing FK values are **also updated** to match |
| **SET NULL** | Referencing FK values are set to `NULL` | Referencing FK values are set to `NULL` |
| **SET DEFAULT** | Referencing FK values are reset to a predefined default | Referencing FK values are reset to a predefined default |

**SQL Syntax Example:**

```sql
CREATE TABLE DEPT (
    DNUMBER INTEGER PRIMARY KEY,
    MGRSSN  CHAR(9),
    FOREIGN KEY (MGRSSN) REFERENCES EMP
        ON DELETE SET DEFAULT
        ON UPDATE CASCADE
);
```

Here, if an `EMP` row referenced by `MGRSSN` is deleted, `MGRSSN` reverts to its default value; if that `EMP`'s SSN is updated, the change **cascades** into `DEPT.MGRSSN` automatically.

> **Tricky question:** "Why might CASCADE be dangerous for DELETE but perfectly safe for UPDATE in many designs?" → A cascading **DELETE** can trigger an unintended chain reaction, silently wiping out large amounts of related data (e.g., deleting a department cascades to delete all its employees, which could cascade further); a cascading **UPDATE** (like propagating a changed primary key) is usually far less destructive since no data is being removed, just re-labeled — hence UPDATE CASCADE is far more commonly used than DELETE CASCADE in practice.

### 6.3 Domain Constraints — Beyond Basic Data Types

Modern SQL also supports:
- **CHECK constraints:** `CHECK (Salary > 0)`, `CHECK (Grade IN ('A','B','C','D','F'))`.
- **Named domains:** `CREATE DOMAIN` in SQL-99, allowing reusable custom domains with built-in constraints (e.g., a `SSN_TYPE` domain that's always a 9-character string matching a pattern).

### 6.4 Assertions

> **Definition:** An **Assertion** is a general, standalone integrity constraint defined via `CREATE ASSERTION`, expressing a condition that must always hold, potentially spanning **multiple tables** — unlike a `CHECK` constraint, which is tied to a single table/column.

**Worked Example:** Ensure that the sum of employee salaries in a department never exceeds the department's budget:

```sql
CREATE ASSERTION SALARY_CONSTRAINT
CHECK (
  NOT EXISTS (
    SELECT DNO
    FROM EMPLOYEE
    GROUP BY DNO
    HAVING SUM(SALARY) > (SELECT BUDGET FROM DEPARTMENT WHERE DEPARTMENT.DNO = EMPLOYEE.DNO)
  )
);
```

> **Tricky question:** "Why aren't assertions as commonly implemented/performant as table-level CHECK constraints?" → Because the DBMS must **re-evaluate the assertion's condition against potentially multiple tables on every relevant modification** anywhere in those tables — this is far more expensive than a simple single-row, single-table CHECK, so many production systems favor triggers or application-level logic over assertions for performance reasons.

### 6.5 Views (Cross-Reference from Lecture 3, Integrity Angle)

Views also serve integrity/security goals:
- A view can **restrict rows** (e.g., `WHERE Dno = 5`) so a departmental manager only ever sees their own department's employees, enforcing row-level security without separate access-control logic per query.
- A view can **restrict columns** (hide `Salary`), enforcing column-level confidentiality.

**Recap — Updatable View Rule (see Lecture 3 §3.4):** joins, GROUP BY, aggregate functions, and DISTINCT generally make a view non-updatable.

### 6.6 Question Bank — Lecture 6

**Short Answer:**
1. List the four integrity constraints and give one violation example for each.
2. Differentiate between RESTRICT, CASCADE, and SET NULL as referential actions.
3. What is an Assertion, and how does it differ from a CHECK constraint?
4. Why is `ON DELETE CASCADE` considered riskier than `ON UPDATE CASCADE`?

**Long Answer:**
1. Design a `FOREIGN KEY` clause for an `ORDERS` table referencing a `CUSTOMERS` table such that deleting a customer sets their orders' customer reference to NULL, but updating a customer ID cascades. Write the full SQL.
2. Explain, with an example spanning two tables, why an Assertion might be necessary where a simple CHECK constraint would be insufficient.
3. Discuss how views contribute to enforcing both entity-level and column-level security in a multi-user database.

**Tricky / Conceptual Traps:**
1. "A CHECK constraint can reference values in another table just as easily as an Assertion." → **False** (in standard SQL) — `CHECK` constraints are conceptually meant for single-table/single-row validation; cross-table rules are the domain of Assertions (though some RDBMSs technically permit subqueries in CHECK with caveats/limitations).
2. "Entity integrity and referential integrity both concern primary keys." → **Partially true but a common trap** — Entity Integrity concerns the primary key of the *same* relation (must not be NULL); Referential Integrity concerns how a *foreign key in one relation* relates to the *primary key of another* (or the same) relation.
3. Can a foreign key be NULL? (→ **Yes**, unless explicitly constrained otherwise — a NULL FK simply means "not yet related to any parent tuple," and referential integrity is not violated by NULL FK values.)

---

## LECTURE 7: Joins

### 7.1 Join Taxonomy

| Join Type | Notation | Definition | Notes |
|---|---|---|---|
| **Theta Join** | $R \Join_{\theta} S$ | Combines tuples from $R$ and $S$ satisfying a general condition $\theta$ using any comparison operator ($<, >, \leq, \geq, =, \neq$) | Most general join form |
| **Equijoin** | $R \Join_{A=B} S$ | A Theta Join restricted specifically to the **equality** operator | Retains both joined attributes (even though they hold equal values) |
| **Natural Join** | $R * S$ | An Equijoin that automatically joins on **all identically named attributes** and eliminates the redundant duplicate column(s) | Most commonly used in practice |

**Worked Example:**

`EMPLOYEE(Ssn, Name, Dno)` and `DEPARTMENT(Dnumber, Dname)`.

- **Theta/Equijoin:** $EMPLOYEE \Join_{Dno = Dnumber} DEPARTMENT$ → result retains **both** `Dno` and `Dnumber` columns (redundant, equal values).
- **Natural Join** (after renaming `Dnumber` to `Dno` for compatibility, or if already same-named): $EMPLOYEE * DEPARTMENT$ → result has only **one** `Dno` column.

> **Tricky question:** "Does Natural Join always give the same *number of rows* as an Equijoin on the same condition?" → **Yes**, they select the same underlying tuples — Natural Join only differs by **eliminating the duplicate column**, not by changing which rows qualify.

### 7.2 Outer Joins — Preserving Unmatched Tuples

Regular (inner) joins **discard** any tuple that has no matching counterpart. Outer joins **preserve** them, padding missing attribute values with `NULL`.

| Outer Join Type | Preserves Unmatched Tuples From |
|---|---|
| **LEFT OUTER JOIN** | The left (first-listed) relation |
| **RIGHT OUTER JOIN** | The right (second-listed) relation |
| **FULL OUTER JOIN** | Both relations |

**Worked Example:** List every employee and their department, **including** employees not yet assigned to any department:

```sql
SELECT E.Name, D.Dname
FROM EMPLOYEE E LEFT OUTER JOIN DEPARTMENT D
ON E.Dno = D.Dnumber;
```

Employees with `Dno = NULL` (or no matching department) still appear, with `Dname` shown as `NULL`.

> **Tricky question:** "If I swap LEFT OUTER JOIN to RIGHT OUTER JOIN but swap the table order too, is the result identical?" → **Yes** — `A LEFT OUTER JOIN B` ≡ `B RIGHT OUTER JOIN A` (same preserved side, same result set), a frequently tested equivalence.

### 7.3 Division Operation (Cross-Reference)

Although categorized separately in some syllabi, **DIVISION** ($\div$) is closely related to join-style reasoning for "for-all" queries:

**Example:** "Find employees who work on **all** projects that department 5 controls."

$$R \div S$$ conceptually returns tuples of $R$ that are associated with **every** tuple in $S$ — implemented via a combination of PROJECT, set DIFFERENCE, and CARTESIAN PRODUCT when derived from more primitive operations (since DIVISION is not strictly primitive).

### 7.4 Question Bank — Lecture 7

**Short Answer:**
1. Differentiate between Theta Join, Equijoin, and Natural Join.
2. What is the key difference between an inner join and an outer join?
3. Why does a Natural Join have one fewer column than the corresponding Equijoin?
4. Which SQL join type would you use to list all departments, including those with zero employees?

**Long Answer:**
1. Given `EMPLOYEE(Ssn, Name, Dno)` and `DEPARTMENT(Dnumber, Dname, Mgr_ssn)`, write SQL for: (a) an inner join listing employee name and department name, (b) a LEFT OUTER JOIN version that also includes unassigned employees, (c) a FULL OUTER JOIN that would also include departments with no employees.
2. Explain the DIVISION operation with a full worked example over small sample relations (e.g., `EMPLOYEE_PROJECTS` and `DEPT5_PROJECTS`).
3. Discuss why "an accidental Cartesian Product often masquerades as a forgotten join" — connect this to the danger discussed in Lecture 1.

**Tricky / Conceptual Traps:**
1. "A Natural Join requires the joining attributes to have the same name AND the same data type/domain." → **True** — matching only by name without domain compatibility would be meaningless; Natural Join implicitly assumes both.
2. "An outer join can never produce more rows than the corresponding Cartesian Product." → **True**, trivially — outer joins are always a *constrained* subset/superset relative to full combinatorial explosion, never exceeding it.
3. Why might a FULL OUTER JOIN sometimes be simulated as `(LEFT OUTER JOIN) UNION (RIGHT OUTER JOIN)` in RDBMSs that lack native FULL OUTER JOIN support?

---

## LECTURE 8: Nested Subqueries

### 8.1 Basic Nested Subqueries

> **Definition:** A **subquery** (inner query) is a complete `SELECT` statement embedded inside another query's `WHERE`, `HAVING`, or `FROM` clause, whose result set is used by the **outer query**.

**Worked Example — Uncorrelated (Independent) Subquery:**

```sql
SELECT Name
FROM EMPLOYEE
WHERE Dno IN (
    SELECT Dnumber FROM DEPARTMENT WHERE Dname = 'Research'
);
```

The inner query executes **once**, independently, producing a fixed set of department numbers; the outer query then filters against that fixed set.

**Comparison operators used with subqueries:** `IN`, `NOT IN`, `= ANY`, `= ALL`, `>`, `<`, etc., combined with `ANY`/`ALL` for multi-row comparisons, and `EXISTS`/`NOT EXISTS`.

### 8.2 Correlated Subqueries

> **Definition:** A subquery that **references a column from the outer query** — meaning it cannot be evaluated once and reused; it must be **re-evaluated for every tuple** processed by the outer query.

**Worked Example:**

```sql
SELECT E.Name
FROM EMPLOYEE E
WHERE EXISTS (
    SELECT *
    FROM DEPENDENT D
    WHERE D.Essn = E.Ssn
);
```

Here, the inner query's `D.Essn = E.Ssn` condition references `E`, the outer query's current row — so the inner query must run once *per employee row* in the outer query.

> **"So What?" — Performance Note:** Correlated subqueries are **computationally expensive** relative to uncorrelated ones precisely because of this per-row re-evaluation; query optimizers often try to **rewrite correlated subqueries as joins** internally where semantically equivalent, to avoid this overhead.

### 8.3 EXISTS / NOT EXISTS — Universal Quantification via Negation

> `EXISTS` tests whether a subquery's result set is **non-empty**. `NOT EXISTS` tests whether it is **empty**.

This is the SQL mechanism for implementing **universal quantification** ($\forall$), by leveraging the calculus equivalence:

$$(\forall t)(COND(t)) \equiv \neg(\exists t)(\neg COND(t))$$

**Worked Example — "Find employees who work on ALL projects controlled by department 5" (the canonical universal-quantification query):**

```sql
SELECT E.Name
FROM EMPLOYEE E
WHERE NOT EXISTS (
    (SELECT P.Pnumber FROM PROJECT P WHERE P.Dnum = 5)
    EXCEPT
    (SELECT W.Pno FROM WORKS_ON W WHERE W.Essn = E.Ssn)
);
```

**Reading it aloud:** "Retrieve employees such that **there is no** project (controlled by dept 5) that is **NOT** among the projects that employee works on" — i.e., "no project is missing," i.e., "works on all of them."

### 8.4 Nested Subquery vs. Join — When to Use Which

| Scenario | Prefer |
|---|---|
| Simple membership test against a fixed list | Subquery with `IN` |
| Need columns from **both** tables in the final result | JOIN (subqueries in `WHERE` cannot project columns from the inner query into the outer `SELECT` list directly) |
| "For all" / universal quantification logic | `NOT EXISTS` (double-negation pattern) |
| Existence check without needing inner data itself | `EXISTS` / `NOT EXISTS` |

> **Tricky question:** "Can a subquery in the FROM clause (a 'derived table') expose its columns to the outer SELECT list?" → **Yes** — unlike a WHERE-clause subquery, a `FROM`-clause subquery is treated as a temporary named relation and its columns **can** be selected directly by the outer query.

### 8.5 Question Bank — Lecture 8

**Short Answer:**
1. Differentiate between correlated and uncorrelated (nested) subqueries.
2. Why are correlated subqueries considered expensive?
3. What is the SQL equivalent of universal quantification, and how is it constructed?
4. Can a WHERE-clause subquery's columns appear in the outer SELECT list? Why or why not?

**Long Answer:**
1. Write both a correlated and an uncorrelated subquery to solve two different (but related) problems over `EMPLOYEE` and `DEPENDENT`, explaining why each style was chosen.
2. Fully explain, step by step, the "employees who work on all projects of department 5" query using `NOT EXISTS`/`EXCEPT`, including why single-negation (`NOT IN`) is insufficient for this universal case.
3. Discuss how query optimizers may internally transform correlated subqueries into joins, and why this transformation is valuable.

**Tricky / Conceptual Traps:**
1. "`NOT IN` and `NOT EXISTS` always produce identical results." → **False, subtle NULL trap** — if the subquery's result set (for `NOT IN`) contains even a single `NULL`, the entire `NOT IN` condition can evaluate to `UNKNOWN` for all rows, effectively returning **zero rows** — a classic, dangerous SQL bug. `NOT EXISTS` does not suffer from this NULL trap.
2. "A subquery must always return a single value to be used with `=`." → **True for plain `=`** — using `=` against a subquery returning multiple rows causes a runtime error; multi-row comparisons require `IN`, `ANY`, or `ALL`.
3. Why might a nested subquery using `IN` sometimes be less efficient than an equivalent `JOIN`, even though both give the same result? (Optimizers may or may not successfully rewrite one into the other depending on the RDBMS and query complexity.)

---

## LECTURE 9: Stored Procedures, Triggers, and Overview of Query Optimization

### 9.1 Stored Procedures

> **Definition:** A **Stored Procedure** is a named, precompiled block of SQL (and often procedural extensions like loops/conditionals, e.g., PL/SQL or T-SQL) stored on the database server, invoked by name rather than transmitted as raw SQL text each time.

**Benefits:**
- **Reduced network traffic:** Client sends a short procedure call instead of a full SQL script.
- **Performance:** Precompiled execution plans avoid repeated parsing/optimization overhead.
- **Encapsulation/Reuse:** Business logic is centralized on the server, reusable across multiple applications.
- **Security:** Users can be granted `EXECUTE` privilege on a procedure without direct table access, restricting *how* they can touch the data.

**Simplified Syntax Sketch (illustrative, syntax varies by RDBMS):**

```sql
CREATE PROCEDURE Raise_Salary (IN emp_ssn CHAR(9), IN pct DECIMAL(5,2))
BEGIN
    UPDATE EMPLOYEE
    SET Salary = Salary + (Salary * pct / 100)
    WHERE Ssn = emp_ssn;
END;
```

### 9.2 Triggers — The Event-Condition-Action (ECA) Model

> **Definition:** A **Trigger** is an *active* database rule that automatically executes an action when a specified event occurs and (optionally) a condition is satisfied — the **Event-Condition-Action (ECA)** paradigm.

| Component | Meaning |
|---|---|
| **Event** | A DML operation (`INSERT`, `UPDATE`, `DELETE`) on a specified table/column |
| **Condition** | An optional boolean check; the action only fires if this condition holds |
| **Action** | The procedural response — could be another DML statement, a stored procedure call, a rejection, or a logging action |

**Trigger Timing:** `BEFORE` (validate/modify before the change is applied) or `AFTER` (react once the change has been committed to the row).

**Trigger Granularity:** `ROW-level` (fires once per affected row) or `STATEMENT-level` (fires once per triggering statement, regardless of rows affected).

**Worked Example:**

```sql
CREATE TRIGGER Salary_Check
BEFORE UPDATE OF Salary ON EMPLOYEE
FOR EACH ROW
WHEN (NEW.Salary > OLD.Salary * 1.5)
BEGIN
    -- reject or log an unusually large raise
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Raise exceeds 50% limit';
END;
```

> **Tricky question:** "How does a Trigger differ from an Assertion, since both can enforce cross-row or cross-table rules?" → An **Assertion** is a *passive*, declarative constraint checked automatically by the DBMS on any relevant change, with no explicit "action" logic beyond "reject if violated." A **Trigger** is *active* and *procedural* — it can execute arbitrary custom logic (logging, cascading custom updates, sending alerts) beyond simple rejection, giving it far greater flexibility (at the cost of being harder to reason about/maintain, since triggers can chain and fire other triggers).

### 9.3 Stored Procedures vs. Triggers vs. Assertions

| Aspect | Stored Procedure | Trigger | Assertion |
|---|---|---|---|
| Invocation | Explicitly **called** by name | **Automatically fires** on a DML event | **Automatically checked** on any relevant modification |
| Nature | Procedural logic block | ECA rule (event-driven) | Declarative constraint |
| Typical use | Encapsulating reusable business logic | Enforcing business rules, auditing, cascading custom logic | Enforcing cross-table integrity rules |

### 9.4 Overview of Query Optimization

> **Pipeline:** Parsing → Query Tree/Graph Generation → Optimization Strategy Selection → Execution Plan → Execution.

**Key Concepts:**
1. **Parsing:** The SQL query is checked for syntax correctness and translated into an internal representation (a **query tree**, where leaf nodes are base relations and internal nodes are algebra operations).
2. **Heuristic (Rule-Based) Optimization:** Applies general "good practice" transformation rules to the query tree *before* considering cost, such as:
 - Performing `SELECT` (filtering) operations **as early as possible** (push selections down the tree) to shrink intermediate relation sizes.
 - Performing `PROJECT` operations early to reduce the number of columns carried through intermediate steps.
 - Combining a cascade of SELECTs into one, and a cascade of PROJECTs into one.
 - Reordering joins so that the most restrictive (smallest-result) joins happen earliest.
3. **Cost-Based Optimization:** Uses statistics (table sizes, index availability, data distribution/histograms) to estimate the **cost** (I/O, CPU) of multiple candidate execution plans and select the cheapest.
4. **Execution Plan:** The final, chosen low-level procedural plan (specific join algorithms, access paths/indexes) that the engine actually executes.

> **"So What?" of Optimization:** This pipeline is precisely what allows a user to write a purely *declarative* SQL statement (the "what") while the engine independently determines the most efficient *procedural* path (the "how") — turning what might be an hours-long naive execution into a millisecond response, especially critical at production scale.

### 9.5 Question Bank — Lecture 9

**Short Answer:**
1. Define a Stored Procedure and list two of its benefits.
2. What does ECA stand for in the context of Triggers?
3. Differentiate between BEFORE and AFTER triggers.
4. Differentiate between ROW-level and STATEMENT-level trigger granularity.
5. List the four stages of the query optimization pipeline.

**Long Answer:**
1. Compare and contrast Stored Procedures, Triggers, and Assertions in terms of invocation, nature, and typical use cases.
2. Explain heuristic query optimization's "push selections down the tree" strategy with a worked example query tree before and after optimization.
3. Discuss why cost-based optimization requires database statistics, and what happens if those statistics become stale/outdated.

**Tricky / Conceptual Traps:**
1. "A trigger can only respond to changes; it can never prevent them." → **False** — a `BEFORE` trigger can inspect/reject or modify data *before* the change is committed, effectively acting as a gatekeeper, not just a reactive logger.
2. "Heuristic optimization guarantees the absolute fastest possible query plan." → **False** — heuristics apply generally sound rules but do not guarantee optimality; cost-based optimization (using actual statistics) is needed to compare among multiple heuristically-valid plans and pick the genuinely cheapest one.
3. Why might overusing triggers across many tables lead to maintenance difficulty? (Cascading/chained trigger firing can create hard-to-trace, implicit control flow — often called "trigger spaghetti" — making the overall system behavior difficult to predict or debug.)

---

## Master Comparison Tables (Cross-Cutting — High-Yield for Exams)

### A. Relational Algebra vs. SQL vs. Relational Calculus

| Aspect | Relational Algebra | SQL | Relational Calculus |
|---|---|---|---|
| Paradigm | Procedural | Mostly declarative (practical) | Declarative (formal) |
| Duplicate handling | True sets (no duplicates) | Bags by default (duplicates allowed) | True sets, formally |
| Primary use | Theoretical foundation / optimizer internals | Practical implementation language | Theoretical foundation / expressiveness proofs |

### B. Referential Actions Summary

| Action | On Parent DELETE | On Parent Key UPDATE | Risk Level |
|---|---|---|---|
| RESTRICT | Blocks the operation | Blocks the operation | Safe but inflexible |
| CASCADE | Deletes children too | Updates children's FK too | High risk on DELETE, lower on UPDATE |
| SET NULL | Children's FK → NULL | Children's FK → NULL | Moderate (loses relationship info) |
| SET DEFAULT | Children's FK → default value | Children's FK → default value | Moderate (relationship reassigned to default) |

### C. Correlated vs. Uncorrelated Subqueries

| Aspect | Uncorrelated | Correlated |
|---|---|---|
| Inner query depends on outer row? | No | Yes |
| Evaluated | Once | Once per outer row |
| Performance | Generally cheaper | Generally more expensive |
| Typical use | `IN`, fixed-list membership | `EXISTS`, per-row existence checks |

### D. Views vs. Stored Procedures vs. Triggers vs. Assertions

| Aspect | View | Stored Procedure | Trigger | Assertion |
|---|---|---|---|---|
| Stores data? | No (virtual) | No (stores logic) | No (stores logic) | No (stores a rule) |
| Invocation | Queried like a table | Explicitly called | Fires automatically on event | Checked automatically on modification |
| Main purpose | Simplification / security | Reusable business logic | Reactive business rules / auditing | Declarative multi-table constraint |

---

## Final High-Value "Tricky Question" Round-Up

1. **Q:** Is a Natural Join always equivalent in row-count to an Equijoin on the same matching attributes?
 **A:** Yes — they select the same rows; Natural Join merely removes the duplicate column.

2. **Q:** Does `COUNT(*)` count rows with NULL in every column?
 **A:** Yes — `COUNT(*)` counts rows regardless of NULLs; only `COUNT(column)` excludes NULLs in that specific column.

3. **Q:** Can PROJECT reduce the number of tuples in a result even though it doesn't filter rows?
 **A:** Yes — because dropping columns can make previously distinct tuples become identical, and duplicates are removed in true relational algebra.

4. **Q:** Why is `NOT IN` dangerous when the subquery might return NULL?
 **A:** A single NULL in the `NOT IN` list makes the entire condition evaluate to `UNKNOWN` for every row, silently returning zero results — use `NOT EXISTS` instead for safety.

5. **Q:** Is Entity Integrity about foreign keys or primary keys?
 **A:** Primary keys — Entity Integrity guarantees a PK is never NULL. Referential Integrity is the FK-related rule.

6. **Q:** Can a view with a `WHERE` clause (but no join, aggregate, or DISTINCT) be updated?
 **A:** Generally yes, provided it includes the base table's primary key and doesn't otherwise violate updatability rules.

7. **Q:** Does adding `NOT NULL` work immediately when you `ALTER TABLE ADD` a column to a table with existing rows?
 **A:** No — existing rows get NULL for the new column first; NOT NULL can only be enforced after populating real values.

8. **Q:** Is SQL's `SELECT` statement itself DDL, DML, or DCL?
 **A:** DML — it's the data-retrieval component of Data Manipulation Language.

9. **Q:** Why does an Assertion typically cost more than a CHECK constraint?
 **A:** An assertion may need to be re-evaluated against changes in *multiple* tables, unlike a CHECK constraint scoped to a single table/row.

10. **Q:** In `A LEFT OUTER JOIN B`, which side is padded with NULLs for unmatched tuples?
 **A:** The **right** side's columns are padded with NULL for rows from the left table that have no match — the *left* table's rows are always fully preserved.

---

*End of enhanced notes. Recommended next step: practice writing relational algebra, TRC, and equivalent SQL for the same query (e.g., "list employees who work on all projects controlled by department 5") to solidify the mapping between the procedural, calculus-based, and practical SQL representations of the identical logical request.*
